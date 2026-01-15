# Readify - Session Notes

## Apa yang sudah dikerjakan

### HomePage UI

- Background dan ground dari `assets/untukhome/`
- Huruf "READIFY" dengan animasi floating (r-e-a-d-i-f-y)
- Karakter anak dengan animasi bounce
- Tombol play dengan animasi zoom out saat diklik
- Tombol menu (orang tua), exit, sound, dan video

### Audio

- Background music (`assets/musik.mp3`) - loop, volume 50%
- Sound effect button click (`assets/AudioClip/button.wav`)
- Tombol sound untuk toggle on/off backsound
- Menggunakan package `just_audio`

### Animasi

- Semua tombol punya animasi scale (zoom out) saat ditekan
- Huruf READIFY floating naik-turun
- Karakter bounce naik-turun

### Assets yang digunakan

```
assets/untukhome/
├── bg.png
├── ground.png
├── karakter.png
├── button_play.png
├── tombol exit.png
├── tombol sound.png
├── huruf kecil_r.png
├── huruf kecil_e.png
├── huruf kecil_a.png
├── huruf kecil_d.png
├── huruf kecil_i.png
├── huruf kecil_f.png
└── huruf kecil_y.png

assets/
├── musik.mp3
└── AudioClip/button.wav
```

## Yang belum diimplementasi

- Fungsi tombol Play (navigasi ke game)
- Fungsi tombol Menu (orang tua)
- Fungsi tombol Video
- Exit dialog menggunakan asset lama (`assets/Sprite/`)

## Dependencies

```yaml
just_audio: ^0.9.40
```

## Catatan Teknis

- Orientasi: Landscape only
- Fullscreen: Immersive sticky mode
- Audio: BGM dan SFX menggunakan player terpisah agar tidak saling ganggu
