/* global $, React, EXIF */
/* eslint-disable no-unused-vars */

class Recognizer extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            faces: []
        };
    }
    updateFaces(faces, message) {
        this.setState({
            faces: faces,
            message: message
        });
    }
    changeLoadingState(loading) {
        if (loading) {
            this.setState({
                faces: [],
                message: 'loading...',
                loading: true
            });
        } else {
            this.setState({
                loading: false
            });
        }
    }
    componentDidMount() {
        this.setState({
            loaderSize: this.refs.loader.size + 1
        });
    }
    render() {
        return (
            <div className="row">
              <div className="col-xs-12 col-sm-9 col-md-8 col-lg-6">
                <ImageLoader ref="loader" updateFaces={this.updateFaces.bind(this)} changeLoadingState={this.changeLoadingState.bind(this)}/>
                <Loading display={this.state.loading} size={this.state.loaderSize}/>
              </div>
              <div className="col-xs-12 col-sm-9 col-md-4 col-lg-6">
                <ResultList faces={this.state.faces} message={this.state.message}/>
              </div>
            </div>
        );
    }
}

class ImageLoader extends React.Component {
    drawImage(image) {
        const ctx = this.refs.canvas.getContext('2d');
        const h = image.height;
        const w = image.width;
        const scale = Math.max(w / this.size, h / this.size);
        let offset_x = (this.size - w / scale) / 2.0;
        let offset_y = (this.size - h / scale) / 2.0;
        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, this.size, this.size);
        /* rotate image */
        EXIF.getData(image, () => {
            const transforms = {
                1: [1, 0, 0, 1, 0, 0],
                2: [-1, 0, 0, 1, this.size, 0],
                3: [-1, 0, 0, -1, this.size, this.size],
                4: [1, 0, 0, -1, 0, this.size],
                5: [0, 1, 1, 0, 0, 0],
                6: [0, 1, -1, 0, this.size, 0],
                7: [0, -1, -1, 0, this.size, this.size],
                8: [0, -1, 1, 0, 0, this.size]
            };
            this.orientation = EXIF.getTag(image, 'Orientation');
            ctx.transform(...transforms[this.orientation || 1]);
            ctx.drawImage(image, offset_x, offset_y, w / scale, h / scale);
            ctx.setTransform(...transforms[1]);
            if ((this.orientation || 1) > 4) {
                [offset_x, offset_y] = [offset_y, offset_x];
            }
        });
        /* post to api */
        const req = this.req = Math.floor(Math.random() * 0xFFFFFFFF);
        this.props.changeLoadingState(true);
        $.ajax({
            url: '/recognizer/api.json',
            method: 'POST',
            data: {
                image: image.src
            },
            success: (result) => {
                if (this.req !== req) {
                    return;
                }
                this.props.changeLoadingState(false);
                const rotate = (target, center, rad) => {
                    return {
                        x:   Math.cos(rad) * target.x + Math.sin(rad) * target.y - center.x * Math.cos(rad) - center.y * Math.sin(rad) + center.x,
                        y: - Math.sin(rad) * target.x + Math.cos(rad) * target.y + center.x * Math.sin(rad) - center.y * Math.cos(rad) + center.y
                    };
                };
                const face_url = (face) => {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    const radian = face.angle.roll * Math.PI / 180.0;
                    const s = 96 / Math.max(Math.abs(face.bounding[0].x - face.bounding[2].x), Math.abs(face.bounding[0].y - face.bounding[2].y));
                    const transforms = {
                        1: [1, 0, 0, 1, 0, 0],
                        2: [-1, 0, 0, 1, w, 0],
                        3: [-1, 0, 0, -1, w, h],
                        4: [1, 0, 0, -1, 0, h],
                        5: [0, 1, 1, 0, 0, 0],
                        6: [0, 1, -1, 0, h, 0],
                        7: [0, -1, -1, 0, h, w],
                        8: [0, -1, 1, 0, 0, w]
                    };
                    canvas.width = canvas.height = 112;
                    ctx.translate(56, 56);
                    ctx.scale(s, s);
                    ctx.rotate(-radian);
                    ctx.translate(-(face.bounding[0].x + face.bounding[2].x) / 2.0, -(face.bounding[0].y + face.bounding[2].y) / 2.0);
                    ctx.transform(...transforms[this.orientation || 1]);
                    ctx.drawImage(image, 0, 0);
                    ctx.transform(...transforms[1]);
                    return canvas.toDataURL();
                };
                const faces = [];
                result.faces.forEach((face) => {
                    const v = face.bounding.map((e) => {
                        return {
                            x: e.x / scale + offset_x,
                            y: e.y / scale + offset_y
                        };
                    });
                    const center = {
                        x: (v[0].x + v[2].x) / 2.0,
                        y: (v[0].y + v[2].y) / 2.0
                    };
                    const radian = face.angle.roll * Math.PI / 180.0;
                    const p = v.map((e) => rotate(e, center, -radian));
                    ctx.lineWidth = 2;
                    ctx.strokeStyle = '#8888FF';
                    ctx.beginPath();
                    ctx.moveTo(p[0].x, p[0].y);
                    ctx.lineTo(p[1].x, p[1].y);
                    ctx.lineTo(p[2].x, p[2].y);
                    ctx.lineTo(p[3].x, p[3].y);
                    ctx.closePath();
                    ctx.stroke();

                    faces.push({
                        url: face_url(face),
                        results: face.recognize.sort((a, b) => b[1] - a[1]).splice(0, 5)
                    });
                });
                this.props.updateFaces(faces, result.message);
            },
            error: (_, e) => {
                this.props.changeLoadingState(false);
                this.props.updateFaces([], e);
            }
        });
    }
    readFile(file) {
        const reader = new window.FileReader();
        reader.onload = (e) => {
            const image = new window.Image();
            image.onload = this.drawImage.bind(this, image);
            image.onerror = () => {
                const ctx = this.refs.canvas.getContext('2d');
                ctx.fillStyle = '#000';
                ctx.fillRect(0, 0, this.size, this.size);
                alert('Failed to load image.');
            };
            image.src = e.target.result;
        };
        reader.readAsDataURL(file);
    }
    componentDidMount() {
        this.size = Math.min($(window).width() - 30, 512);
        this.refs.canvas.width = this.refs.canvas.height = this.size;
        this.refs.canvas.addEventListener('dragover', (e) => {
            e.preventDefault();
        });
        this.refs.canvas.addEventListener('drop', (e) => {
            e.stopPropagation();
            e.preventDefault();
            if (e.dataTransfer.files.length > 0) {
                this.readFile(e.dataTransfer.files[0]);
            }
        });
        this.refs.file.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.readFile(e.target.files[0]);
            }
        });
    }
    render() {
        return (
            <div>
              <canvas ref="canvas" style={{border: '1px gray solid'}}></canvas>
              <p>drag and drop or select image.</p>
              <input ref="file" type="file" accept="image/*" id="file"/>
            </div>
        );
    }
}

class ResultList extends React.Component {
    render() {
        const faces = this.props.faces.map((e, i) => {
            const results = e.results.map((r, j) => {
                const text = `${r[0]}: ${r[1]}`;
                const li = j == 0 ? <strong>{text}</strong> : <span>{text}</span>;
                return (
                    <li key={`${i}-${j}`}>{li}</li>
                );
            });
            return (
                <tr key={i}>
                  <td>
                    <img src={e.url}/>
                  </td>
                  <td style={{width: '100%'}}>
                    <ul className="list-unstyled">
                      {results}
                    </ul>
                  </td>
                </tr>
            );
        });
        return (
            <div>
              <p>{this.props.message}</p>
              <table className="table table-hover">
                <tbody>{faces}</tbody>
              </table>
            </div>
        );
    }
}

class Loading extends React.Component {
    render() {
        const size = this.props.size || 0;
        return (
            <div ref="loading" style={{position: 'absolute', top: '0px', backgroundColor: 'gray', opacity: '0.75', width: size, height: size, display: this.props.display ? 'block' : 'none'}}>
              <div className='uil-loading-css' style={{transform: 'scale(1)', top: (size - 200) / 2.0, left: (size - 200) / 2.0}}>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(0deg) translate(0,-60px)',   transform: 'rotate(0deg) translate(0,-60px)',   borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(30deg) translate(0,-60px)',  transform: 'rotate(30deg) translate(0,-60px)',  borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(60deg) translate(0,-60px)',  transform: 'rotate(60deg) translate(0,-60px)',  borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(90deg) translate(0,-60px)',  transform: 'rotate(90deg) translate(0,-60px)',  borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(120deg) translate(0,-60px)', transform: 'rotate(120deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(150deg) translate(0,-60px)', transform: 'rotate(150deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(180deg) translate(0,-60px)', transform: 'rotate(180deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(210deg) translate(0,-60px)', transform: 'rotate(210deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(240deg) translate(0,-60px)', transform: 'rotate(240deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(270deg) translate(0,-60px)', transform: 'rotate(270deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(300deg) translate(0,-60px)', transform: 'rotate(300deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
                <div style={{top: '80px', left: '93px', width: '14px', height: '40px', background: '#cec9c9', WebkitTransform: 'rotate(330deg) translate(0,-60px)', transform: 'rotate(330deg) translate(0,-60px)', borderRadius: '10px', position: 'absolute'}}></div>
              </div>
            </div>
        );
    }
}
