extends Node

# Procedural Sound Synthesizer for Sir Bounce a Lot
# Generates rich 16-bit bouncy retro/cute sound effects and music procedurally
# No external WAV/MP3 files required! Works 100% standalone anywhere.

var sfx_player_pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var bgm_timer: Timer

var sfx_cache: Dictionary = {}
var is_music_enabled: bool = true
var is_sfx_enabled: bool = true

# Musical notes for procedural background music (Pentatonic bouncy scale)
const NOTES = [261.63, 293.66, 329.63, 392.00, 440.00, 523.25, 587.33, 659.25]
var bgm_step: int = 0
var bgm_pattern = [0, 2, 4, 2, 5, 4, 2, 3, 4, 5, 7, 5, 4, 2, 0, 2]
var bgm_bass_pattern = [0, 0, 3, 3, 4, 4, 2, 2]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create pool of audio players
	for i in range(12):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_player_pool.append(p)
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -8.0
	add_child(music_player)

	# Pre-cache procedural sound effects
	_generate_sfx_library()

	# Load attached theme song if available
	var theme_path = "res://assets/audio/theme_song.mp3"
	if ResourceLoader.exists(theme_path):
		var stream = load(theme_path)
		if stream is AudioStreamMP3:
			stream.loop = true
		music_player.stream = stream
		if is_music_enabled:
			music_player.play()
	else:
		# Fallback to procedural background music sequencer
		bgm_timer = Timer.new()
		bgm_timer.wait_time = 0.165
		bgm_timer.timeout.connect(_on_bgm_tick)
		add_child(bgm_timer)
		bgm_timer.start()

func _generate_sfx_library() -> void:
	sfx_cache["jump"] = _generate_tone_sweep(280.0, 580.0, 0.16, "sine", 0.7, 0.02, 0.12)
	sfx_cache["super_bounce"] = _generate_fm_boing(140.0, 680.0, 0.38, 12.0)
	sfx_cache["bumper"] = _generate_chime(880.0, 0.25)
	sfx_cache["ground_pound"] = _generate_ground_pound()
	sfx_cache["coin"] = _generate_two_tone(659.25, 987.77, 0.18)
	sfx_cache["boss_hit"] = _generate_boss_hit()
	sfx_cache["boss_roar"] = _generate_roar()
	sfx_cache["boss_defeat"] = _generate_defeat_fanfare()
	sfx_cache["victory"] = _generate_victory_fanfare()
	sfx_cache["hurt"] = _generate_hurt()
	sfx_cache["pop"] = _generate_pop()
	sfx_cache["charge"] = _generate_tone_sweep(180.0, 380.0, 0.25, "triangle", 0.5, 0.05, 0.18)
	sfx_cache["checkpoint"] = _generate_checkpoint_jingle()

func play_sfx(sfx_name: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	if not is_sfx_enabled or not sfx_cache.has(sfx_name):
		return
	
	var stream = sfx_cache[sfx_name]
	# Find available player
	for p in sfx_player_pool:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale + randf_range(-0.06, 0.06)
			p.volume_db = volume_db
			p.play()
			return
	
	# If all busy, steal first player
	var fallback = sfx_player_pool[0]
	fallback.stream = stream
	fallback.pitch_scale = pitch_scale
	fallback.volume_db = volume_db
	fallback.play()

# Convenience functions
func play_jump(): play_sfx("jump", randf_range(0.95, 1.08))
func play_super_bounce(): play_sfx("super_bounce", 1.0, 2.0)
func play_bumper(): play_sfx("bumper", randf_range(0.9, 1.2), 1.5)
func play_ground_pound(): play_sfx("ground_pound", 1.0, 3.0)
func play_coin(): play_sfx("coin", randf_range(0.98, 1.05))
func play_boss_hit(): play_sfx("boss_hit", 1.0, 2.5)
func play_boss_roar(): play_sfx("boss_roar", 1.0, 2.0)
func play_boss_defeat(): play_sfx("boss_defeat", 1.0, 3.0)
func play_victory(): play_sfx("victory", 1.0, 3.0)
func play_hurt(): play_sfx("hurt", 1.0)
func play_pop(): play_sfx("pop", randf_range(0.9, 1.2))
func play_charge(): play_sfx("charge", randf_range(0.9, 1.1))
func play_checkpoint(): play_sfx("checkpoint", 1.0, 2.5)

func toggle_music() -> bool:
	is_music_enabled = not is_music_enabled
	if music_player and music_player.stream:
		if is_music_enabled:
			if not music_player.playing:
				music_player.play()
			else:
				music_player.stream_paused = false
		else:
			music_player.stream_paused = true
	return is_music_enabled

# Procedural BGM Tick
func _on_bgm_tick() -> void:
	if not is_music_enabled:
		return
	
	var note_idx = bgm_pattern[bgm_step % bgm_pattern.size()]
	var freq = NOTES[note_idx]
	
	# Play cute staccato melody blip
	if bgm_step % 2 == 0 or randf() > 0.4:
		var tone = _generate_tone_sweep(freq, freq * 0.98, 0.12, "sine", 0.35, 0.01, 0.09)
		_play_bgm_tone(tone, 0.95 + (note_idx * 0.02), -15.0)

	# Bass line every 4 steps
	if bgm_step % 4 == 0:
		var bass_idx = bgm_bass_pattern[(bgm_step / 4) % bgm_bass_pattern.size()]
		var bass_freq = NOTES[bass_idx] * 0.5
		var bass_tone = _generate_tone_sweep(bass_freq, bass_freq * 0.95, 0.22, "triangle", 0.5, 0.02, 0.18)
		_play_bgm_tone(bass_tone, 1.0, -13.0)

	bgm_step += 1

func _play_bgm_tone(stream: AudioStreamWAV, pitch: float, vol_db: float) -> void:
	# Use designated background player from pool
	var p = sfx_player_pool[sfx_player_pool.size() - 1]
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = vol_db
	p.play()

# ----------------- PROCEDURAL AUDIO GENERATION HELPERS -----------------

func _generate_tone_sweep(start_freq: float, end_freq: float, duration: float, waveform: String, amp: float, attack: float, decay: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2) # 16-bit signed PCM
	
	var phase = 0.0
	for i in range(total_samples):
		var t = float(i) / float(total_samples)
		var freq = lerp(start_freq, end_freq, t)
		phase += 2.0 * PI * freq / sample_rate
		if phase > 2.0 * PI:
			phase -= 2.0 * PI
		
		# Envelope
		var env = 1.0
		var time_s = float(i) / sample_rate
		if time_s < attack:
			env = time_s / max(attack, 0.0001)
		elif time_s > duration - decay:
			env = max(0.0, (duration - time_s) / max(decay, 0.0001))
		
		# Waveform
		var val = 0.0
		if waveform == "sine":
			val = sin(phase)
		elif waveform == "triangle":
			val = 2.0 * abs(2.0 * (phase / (2.0 * PI) - floor(phase / (2.0 * PI) + 0.5))) - 1.0
		elif waveform == "square":
			val = 1.0 if sin(phase) >= 0 else -1.0
		
		var sample_val = int(clamp(val * env * amp * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_fm_boing(base_freq: float, max_freq: float, duration: float, mod_freq: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var carrier_phase = 0.0
	var mod_phase = 0.0
	
	for i in range(total_samples):
		var t = float(i) / float(total_samples)
		mod_phase += 2.0 * PI * mod_freq / sample_rate
		var mod = sin(mod_phase) * exp(-t * 4.0)
		
		var current_freq = lerp(base_freq, max_freq, 1.0 - t) + (mod * 150.0)
		carrier_phase += 2.0 * PI * current_freq / sample_rate
		
		var env = sin(t * PI)
		var val = sin(carrier_phase) * env * 0.8
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_chime(freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase1 = 0.0
	var phase2 = 0.0
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		phase1 += 2.0 * PI * freq / sample_rate
		phase2 += 2.0 * PI * (freq * 2.01) / sample_rate
		
		var env = exp(-t * 9.0)
		var val = (sin(phase1) * 0.7 + sin(phase2) * 0.3) * env * 0.75
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_two_tone(f1: float, f2: float, duration: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_samples = int(sample_rate * duration)
	var half = total_samples / 2
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase = 0.0
	for i in range(total_samples):
		var cur_freq = f1 if i < half else f2
		phase += 2.0 * PI * cur_freq / sample_rate
		var t = float(i % half) / float(half)
		var env = 1.0 - t * 0.6
		var val = sin(phase) * env * 0.65
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_ground_pound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.35
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase = 0.0
	for i in range(total_samples):
		var t = float(i) / float(total_samples)
		var freq = lerp(160.0, 45.0, t)
		phase += 2.0 * PI * freq / sample_rate
		var noise = randf_range(-0.25, 0.25) * (1.0 - t)
		var env = exp(-t * 6.0)
		var val = (sin(phase) + noise) * env * 0.85
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_boss_hit() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.3
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase = 0.0
	for i in range(total_samples):
		var t = float(i) / float(total_samples)
		var freq = lerp(420.0, 90.0, t * t)
		phase += 2.0 * PI * freq / sample_rate
		var noise = randf_range(-0.35, 0.35)
		var env = exp(-t * 5.0)
		var val = (sin(phase) * 0.7 + noise * 0.3) * env * 0.8
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_roar() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.65
	var total_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase = 0.0
	for i in range(total_samples):
		var t = float(i) / float(total_samples)
		var freq = 90.0 + sin(t * 18.0) * 35.0
		phase += 2.0 * PI * freq / sample_rate
		var distortion = randf_range(-0.45, 0.45)
		var env = sin(t * PI)
		var val = (sin(phase) * 0.6 + distortion * 0.4) * env * 0.8
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_pop() -> AudioStreamWAV:
	return _generate_tone_sweep(350.0, 750.0, 0.08, "sine", 0.6, 0.005, 0.06)

func _generate_hurt() -> AudioStreamWAV:
	return _generate_tone_sweep(280.0, 110.0, 0.22, "triangle", 0.7, 0.01, 0.15)

func _generate_victory_fanfare() -> AudioStreamWAV:
	var sample_rate = 22050
	var notes = [523.25, 659.25, 783.99, 1046.50]
	var duration = 0.7
	var total_samples = int(sample_rate * duration)
	var note_dur = total_samples / 4
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase = 0.0
	for i in range(total_samples):
		var n_idx = mini(i / note_dur, 3)
		var freq = notes[n_idx]
		phase += 2.0 * PI * freq / sample_rate
		var t_note = float(i % note_dur) / float(note_dur)
		var env = 1.0 - t_note * 0.5
		var val = sin(phase) * env * 0.75
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func _generate_defeat_fanfare() -> AudioStreamWAV:
	return _generate_tone_sweep(120.0, 800.0, 0.5, "sine", 0.8, 0.05, 0.3)

func _generate_checkpoint_jingle() -> AudioStreamWAV:
	var sample_rate = 22050
	var notes = [440.0, 554.37, 659.25, 880.0] # A major arpeggio
	var duration = 0.45
	var total_samples = int(sample_rate * duration)
	var note_dur = total_samples / 4
	var data = PackedByteArray()
	data.resize(total_samples * 2)
	
	var phase = 0.0
	for i in range(total_samples):
		var n_idx = mini(i / note_dur, 3)
		var freq = notes[n_idx]
		phase += 2.0 * PI * freq / sample_rate
		var t_note = float(i % note_dur) / float(note_dur)
		var env = 1.0 - t_note * 0.4
		var val = sin(phase) * env * 0.7
		var sample_val = int(clamp(val * 32767.0, -32768, 32767))
		data.encode_s16(i * 2, sample_val)
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
