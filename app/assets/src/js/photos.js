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
            let scale = Math.max(img.width  / this.canvas.width, img.height / this.canvas.height);
            let w = img.width  / scale;
            let h = img.height / scale;
            let offset_x = (this.canvas.width  - w) * 0.5;
            let offset_y = (this.canvas.height - h) * 0.5;
            this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.drawImage(img, offset_x, offset_y, w, h);
            this.faces.faces.forEach((e) => {
                let face = document.createElement('canvas');
                let side = Math.max(e.w * img.width / 100.0, e.h * img.height / 100.0);
                face.width  = side;
                face.height = side;
                let eye_l, eye_r;
                if (e.eyes[0].x > e.eyes[1].x) {
                    eye_r = e.eyes[0];
                    eye_l = e.eyes[1];
                } else {
                    eye_l = e.eyes[0];
                    eye_r = e.eyes[1];
                }
                let ctx = face.getContext('2d');
                let rad = Math.atan2((eye_r.y - eye_l.y) * img.height, (eye_r.x - eye_l.x) * img.width);
                ctx.translate(side * 0.5, side * 0.5);
                ctx.rotate(-rad);
                ctx.translate(-e.center.x * img.width / 100.0, -e.center.y * img.height / 100.0);
                ctx.drawImage(img, 0, 0);
                $(this.detected).append(face);
            });
        };
        if (this.faces) {
            img.src = this.faces.url;
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
