/* global $ */
class Photo {
    constructor(canvas, faces) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.faces = faces;
    }
    draw() {
        const img = new Image();
        img.onload = () => {
            const scale = Math.max(img.width  / this.canvas.width, img.height / this.canvas.height);
            const w = img.width  / scale;
            const h = img.height / scale;
            const offset_x = (this.canvas.width  - w) * 0.5;
            const offset_y = (this.canvas.height - h) * 0.5;
            this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.drawImage(img, offset_x, offset_y, w, h);
        };
        img.src = this.faces.url;
    }
}

$(document).on('ready page:load', () => {
    if (window.location.pathname.match('^/photos/')) {
        const photo = new Photo(window.document.getElementById('canvas'), window.faces);
        photo.draw();
    }
});
