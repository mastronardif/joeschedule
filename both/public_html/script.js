document.addEventListener('DOMContentLoaded', () => {
    const watermark = document.createElement('div');
    watermark.style.position = 'fixed';
    watermark.style.top = '50%';
    watermark.style.left = '50%';
    watermark.style.transform = 'translate(-50%, -50%)';
    watermark.style.fontSize = '5em';
    watermark.style.color = 'rgba(0, 0, 0, 0.1)';
    watermark.style.pointerEvents = 'none';
    watermark.style.zIndex = '9999';
    watermark.style.userSelect = 'none'; // Prevents selection of watermark text
    watermark.textContent = 'WATERMARK';

    document.body.appendChild(watermark);
});
