/* ==========================================================================
   Readify - Children's Game Portal Script
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  initAudioPlayer();
  initModal();
});

function initModal() {
  const modal = document.getElementById('noticeModal');
  const modalTitle = document.getElementById('modalTitle');
  const modalMessage = document.getElementById('modalMessage');
  const closeBtn = document.getElementById('modalCloseBtn');
  const apkBtn = document.getElementById('heroDownloadApk');
  const exeBtn = document.getElementById('heroDownloadExe');

  const openModal = (title, message) => {
    if (modalTitle) modalTitle.textContent = title;
    if (modalMessage) modalMessage.textContent = message;
    if (modal) modal.classList.add('active');
  };

  const closeModal = () => {
    if (modal) modal.classList.remove('active');
  };

  if (apkBtn) {
    apkBtn.addEventListener('click', (e) => {
      if (apkBtn.classList.contains('btn-disabled') || apkBtn.getAttribute('href') === 'javascript:void(0)') {
        e.preventDefault();
        openModal('Versi Android (.APK)', 'Aplikasi Android Readify sedang dalam proses persiapan. Silakan gunakan versi Web terlebih dahulu!');
      }
    });
  }

  if (exeBtn) {
    exeBtn.addEventListener('click', (e) => {
      if (exeBtn.classList.contains('btn-disabled') || exeBtn.getAttribute('href') === 'javascript:void(0)') {
        e.preventDefault();
        openModal('Versi Windows (.EXE)', 'Aplikasi Windows Readify sedang dalam proses persiapan. Silakan gunakan versi Web terlebih dahulu!');
      }
    });
  }

  if (closeBtn) {
    closeBtn.addEventListener('click', closeModal);
  }

  if (modal) {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) closeModal();
    });
  }
}

function initAudioPlayer() {
  const bgMusic = new Audio('assets/audio/musik.mp3');
  bgMusic.loop = true;
  bgMusic.volume = 0.35;

  const audioBtn = document.getElementById('audioToggleBtn');
  let isPlaying = false;

  if (audioBtn) {
    audioBtn.addEventListener('click', () => {
      if (!isPlaying) {
        bgMusic.play().then(() => {
          isPlaying = true;
          audioBtn.classList.add('playing');
          audioBtn.textContent = 'Musik: ON';
        }).catch(err => {
          console.log('Audio playback prevented:', err);
        });
      } else {
        bgMusic.pause();
        isPlaying = false;
        audioBtn.classList.remove('playing');
        audioBtn.textContent = 'Musik: OFF';
      }
    });
  }
}
