/* global $ */
class Photo {
    constructor(canvas, detected) {
        this.canvas   = canvas;
        this.detected = detected;
        this.faces    = window.faces;
        this.ctx = canvas.getContext('2d');
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
            this.faces.faces.forEach((e) => {
                const face = document.createElement('canvas');
                const side = Math.max(e.w * img.width / 100.0, e.h * img.height / 100.0) * Math.sqrt(2);
                const size = 227 * Math.sqrt(2);
                face.width  = size;
                face.height = size;
                let eye_l, eye_r;
                if (e.eyes[0].x > e.eyes[1].x) {
                    eye_r = e.eyes[0];
                    eye_l = e.eyes[1];
                } else {
                    eye_l = e.eyes[0];
                    eye_r = e.eyes[1];
                }
                const ctx = face.getContext('2d');
                const rad = Math.atan2((eye_r.y - eye_l.y) * img.height, (eye_r.x - eye_l.x) * img.width);
                ctx.scale(size / side, size / side);
                ctx.translate(side * 0.5, side * 0.5);
                ctx.rotate(-rad);
                ctx.translate(-e.center.x * img.width / 100.0, -e.center.y * img.height / 100.0);
                ctx.drawImage(img, 0, 0);
                console.log(face.toDataURL('image/jpeg').length);
                $(this.detected).append(face);
            });
        };
        if (this.faces) {
            img.src = '/proxy?url=' + this.faces.url;
        }
    }
}

$(document).on('ready page:load', () => {
    if (window.location.pathname.match('^/photos/')) {
        const photo = new Photo(
            window.document.getElementById('canvas'),
            window.document.getElementById('detected')
        );
        photo.draw();
    }
});
