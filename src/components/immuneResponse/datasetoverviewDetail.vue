<template>
  <div>
    <div class="textitem">
      <div class="tablewidth" v-loading="cardLoading" v-show="diffExpResponShow">
        <p class="card-title">{{title}}</p>
        <el-row v-loading="diffExpResponloading" justify="center">
          <el-col span="20" push="2">
            <div :id="conditi" class="scaterPlot" style="width: 1000px;height:400px;"></div>
          </el-col>
        </el-row>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    conditi: {type: String},
    title: {type: String},
    datasetid: {type: String}
  },

  data() {
    return {
      expands: [],
      diffExpResponShow: true,
      cardLoading: true,
      diffExpResponloading: false,
      loading: false,
      imgpathBox: "",
      getPlotUrl: "",
      detailimgShow: true,
    };
  },
  watch: {
    datasetid: {
      handler(newValue, oldValue) {
        this.datasetid = newValue;
        this.getTableData(this.datasetid, this.conditi);
      },
      deep: true
    }
  },
  computed: {
    imgUrlBox: function () {
      return "tiger/img/" + this.imgpathBox + ".png";
    }
  },

  mounted() {
    this.$nextTick(() => {
      this.getTableData(this.datasetid, this.conditi);
    });
  },

  methods: {

    getTableData(datasetid, conditi) {
      var targetdiv = document.getElementById(this.conditi);
      let myChart_mercor = window.echarts.init(targetdiv);
      myChart_mercor.clear();
      this.cardLoading = true;
      this.$http
        .get("/tiger/responseOverview.php", {
          params: {
            datasetid: datasetid,
            conditi: conditi,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.cardLoading = false;
            // console.log(res.data.list)
            this.diffExpResponShow = res.data.list.length != 0
            this.draw_chart(res.data.list);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    draw_chart(data) {
      var targetdiv = document.getElementById(this.conditi);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);
      var xAxis = "";
      var yAxis = "";
      var xlabname = ""
      if (this.conditi === "Survival") {
        xAxis = "Hazard Ratio";
        yAxis = "–log10(P Value)";
        xlabname = "HR: "
      } else {
        xAxis = "Log2 (Fold Change)";
        yAxis = "–log10(P Value)";
        xlabname = "Fold Change: "
      }

      let option = {
        xAxis: {
          name: xAxis,
          // show: false,
          position: "bottom",
          nameLocation: "center",
          nameGap: 25,
          offset: 0,
          nameTextStyle:{
            fontSize: 18,
            fontWeight: 'bold',
          },
        },
        yAxis: { 
          name: yAxis,
          position: "left",
          nameLocation: "center",
          nameGap: 25,
          nameTextStyle:{
            fontSize: 18,
            fontWeight: 'bold',
          },
        },
        tooltip: {
          formatter: function (params) {
              return "Gene: "+ params.data[2] + "<br />P: " + params.data[1] + "<br />" + xlabname + params.data[0]
          }
        },
        series: [
          {
            symbolSize: 20,
            data: data,
            type: "scatter",
          },
        ],
      };

      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
  },
};
</script>


<style>

.el-table__expand-icon:after{
  /* content: "View";
  color: #09e1c0; */
  cursor: pointer;
}
</style>
