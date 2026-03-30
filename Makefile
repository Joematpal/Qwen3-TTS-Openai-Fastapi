HOST ?= 192.168.50.137
PORT ?= 8880
REF_AUDIO ?= reference.wav
REF_TEXT ?= The exact words spoken in the reference audio.
INPUT_TEXT ?= Hello, this is a cloned voice.
OUTPUT ?= cloned.mp3

.PHONY: up down tts clone clone-xvec

up:
	docker compose up qwen3-tts-gpu

down:
	docker compose down

tts:
	curl -X POST http://$(HOST):$(PORT)/v1/audio/speech \
		-H "Content-Type: application/json" \
		-d '{"model":"tts-1","input":"$(INPUT_TEXT)","voice":"alloy"}' \
		--output speech.mp3

clone:
	$(eval B64 := $(base64 -w0 $(REF_AUDIO)))
	curl -X POST http://$(HOST):$(PORT)/v1/audio/voice-clone \
		-H "Content-Type: application/json" \
		-d '{"input":"$(INPUT_TEXT)","ref_audio":"$(B64)","ref_text":"$(REF_TEXT)","x_vector_only_mode":false}' \
		--output $(OUTPUT)

clone-xvec:
	$(eval B64 := $(shell base64 -w0 $(REF_AUDIO)))
	curl -X POST http://$(HOST):$(PORT)/v1/audio/voice-clone \
		-H "Content-Type: application/json" \
		-d '{"input":"$(INPUT_TEXT)","ref_audio":"$(B64)","x_vector_only_mode":true}' \
		--output $(OUTPUT)
