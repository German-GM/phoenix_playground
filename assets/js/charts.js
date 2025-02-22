import * as echarts from '../vendor/echarts.min'

exports.Chart = {
  mounted() {
    selector = "#" + this.el.id;
    this.chart = echarts.init(this.el.querySelector(selector + "-chart"), null, {
      renderer: 'canvas',
      useDirtyRect: false
    });
    option = JSON.parse(this.el.querySelector(selector + "-data").textContent);

    this.chart.setOption(option);
    window.addEventListener('resize', this.chart.resize);
  },
  updated() {
    selector = "#" + this.el.id;
    option = JSON.parse(this.el.querySelector(selector + "-data").textContent);

    this.chart.setOption(option);
  },
  destroyed() {
    window.removeEventListener('resize', this.chart.resize);
  }
}

exports.ClickSelfOnInterval = {
  mounted() {
    const interval = this.el.dataset.interval || 3000;
    selector = "#" + this.el.id;
    this.interval = setInterval(() => {
      this.el.click();
    }, interval);
  },
  destroyed() {
    clearInterval(this.interval);
  }
}