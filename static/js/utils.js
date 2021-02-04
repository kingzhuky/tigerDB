

const hsv2rgb = function (h, s, v) {
  var rgb, i, data = [];
  if (s === 0) {
    rgb = [v, v, v];
  } else {
    h = h / 60;
    i = Math.floor(h);
    data = [v * (1 - s), v * (1 - s * (h - i)), v * (1 - s * (1 - (h - i)))];
    switch (i) {
      case 0:
        rgb = [v, data[2], data[0]];
        break;
      case 1:
        rgb = [data[1], v, data[0]];
        break;
      case 2:
        rgb = [data[0], v, data[2]];
        break;
      case 3:
        rgb = [data[0], data[1], v];
        break;
      case 4:
        rgb = [data[2], data[0], v];
        break;
      default:
        rgb = [v, data[0], data[1]];
        break;
    }
  }
  return '#' + rgb.map(function (x) {
    return ("0" + Math.round(x * 255).toString(16)).slice(-2);
  }).join('');
}

const gStyle2 = function (val, max) {
  //var max=2.55;

  if (val === 1) {
    return {
      background: 'rgb(241,241,241)',
    }
  } else if (val > 1) {
    const p = val > max ? 1 : (val / max).toFixed(2)
    const v = val > max ? 0.86 : (1 - (val / max) * 0.14).toFixed(2)
    return {
      background: hsv2rgb(0, p, v),
      color: 'rgb(230,230,230)'
    }
  } else if (val < 1) {
    const p = val > max ? 0.56 : ((val / max) * 0.56).toFixed(2)
    const v = val > max ? 0.53 : (1 - (val / max) * 0.47).toFixed(2)
    return {
      background: hsv2rgb(221, p, v),
    }
  }
  return {

    background: "",
    color: ""
  }

}

const gStyle = function (val, max) {
  if (val === 0) {
    return {
      background: 'rgb(241,241,241)',
      cursor: 'not-allowed'
    }
  } else if (val > 0) {
    const p = val > max ? 1 : (val / max).toFixed(2)
    const v = val > max ? 0.86 : (1 - (val / max) * 0.14).toFixed(2)
    return {
      background: hsv2rgb(0, p, v),
      color: val > max * 0.7 ? 'rgb(230,230,230)' : 'black',
      cursor: val > 0.58 ? '' : 'not-allowed',
    }
  }
  const p = -val > max ? 0.56 : ((-val / max) * 0.56).toFixed(2)
  const v = -val > max ? 0.53 : (1 - (-val / max) * 0.47).toFixed(2)
  return {
    cursor: val < -0.58 ? '' : 'not-allowed',
    background: hsv2rgb(221, p, v),
    color: -val > max * 0.7 ? 'rgb(230,230,230)' : 'black'
  }
}

const scrollAnimation = function (currentY, targetY) {
  let needScrollTop = targetY - currentY;
  let _currentY = currentY;
  setTimeout(() => {
    // 一次调用滑动帧数，每次调用会不一样
    const dist = Math.ceil(needScrollTop / 10);
    _currentY += dist;
    document.querySelector("#app").scrollTo(0, currentY);
    // 如果移动幅度小于十个像素，直接移动，否则递归调用，实现动画效果
    if (needScrollTop > 10 || needScrollTop < -10) {
      scrollAnimation(_currentY, targetY);
    } else {
      document.querySelector("#app").scrollTo(0, targetY);
    }
  }, 1);
}

const toTarget = function (param) {
  // const currentY = document.querySelector("#app").scrollTop || document.body.scrollTop;
  // scrollAnimation(currentY, param);
  const pos = document.querySelector("#app").offsetTop + 250 + param 
  console.log(pos)
  window.scrollTo({
    'top': pos,
    'behavior': 'smooth'
  })
}

const toTargetbyid = function (id) {
  var PageId = document.querySelector(id)
  window.scrollTo({
    'top': PageId.offsetTop,
    'behavior': 'smooth'
  })
}

const scrollAnimationLeft = function (id, currentY, targetY) {
  var container = document.querySelector('#' + id + '>.el-table__body-wrapper');
  let needScrollTop = targetY - currentY;
  let _currentY = currentY;
  setTimeout(() => {
    // 一次调用滑动帧数，每次调用会不一样
    const dist = Math.ceil(needScrollTop / 100);
    _currentY += dist;
    container.scrollLeft = currentY;
    //document.querySelector("#app").scrollTo(0, currentY);
    // 如果移动幅度小于十个像素，直接移动，否则递归调用，实现动画效果
    if (needScrollTop > 100 || needScrollTop < -100) {
      scrollAnimationLeft(id, _currentY, targetY);
    } else {
      container.scrollLeft = currentY;
    }
  }, 1);
}

const scrollCol = function (id, param) {
  let container = document.querySelector('#' + id + '>.el-table__body-wrapper');
  const currentY = container.scrollLeft;
  scrollAnimationLeft(id, currentY, param);
}

const scrollRow = function (id, param) {
  let container = document.querySelector('#' + id + '>.el-table__body-wrapper');
  container.scrollTop = param
}



const stop = function () {
  var mo = function (e) {
    e.preventDefault();
  };
  document.body.style.overflow = 'hidden';
  document.addEventListener("touchmove", mo, false); //禁止页面滑动
}
/***取消滑动限制***/
const move = function () {
  var mo = function (e) {
    e.preventDefault();
  };
  document.body.style.overflow = ''; //出现滚动条
  document.removeEventListener("touchmove", mo, false);
}
const onesidecolor = function(min,max,n) {
  if(max == min){
    if(n >0){
      return 'rgb(255,0,0)'
    }else{
      return 'rgb(255,255,255)'
    }
  }
  let c = Math.max(0, (n-min)/(max-min));
  let red = 255;
  let green = (1-c)*255;
  return {
    background: 'rgb('+red+','+green+','+green+')',
    color: 'black',
    cursor: n > 0.58 ? '' : 'not-allowed',
  }
}



export {
  hsv2rgb,
  gStyle,
  gStyle2,
  onesidecolor,
  toTarget,
  scrollCol,
  scrollRow,
  stop,
  move,
  toTargetbyid
}