<template>
  <div class="detail-card">
    <br />
    <br />
    <el-card class="infor">
      <el-row>
        <el-col :push="1" :span="22">
          <p class="title">Data Statistics</p>
          <el-row :gutter="20">
            <el-col :span="12">
              <p class="imgtitle">Cell Statistics in scRNA-Seq</p>
              <div id="scstat_cell" style="width: 600px; height: 500px"></div>
            </el-col>
            <el-col :span="12">
              <p class="imgtitle">Sample Statistics in scRNA-Seq</p>
              <div id="scstat_sample" style="width: 600px; height: 500px"></div>
            </el-col>
          </el-row>
          <el-row :gutter="20" type="flex" justify="space-around">
            <el-col :span="24">
              <p class="imgtitle">Immune Cells Statistics</p>
              <div
                id="immunecellstat"
                style="width: 1200px; height: 320px"
              ></div>
            </el-col>
          </el-row>
          <el-row>
            <el-col :span="16" :push="4">
              <p class="imgtitle">
                Sample Statistics in Bulk RNA-Seq/Microarray
              </p>
              <div id="bulkstat" style="width: 800px; height: 400px"></div>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
      <el-row>
        <el-col :push="1" :span="22">
          <p class="title">Users Statistics</p>
          <br />
          <iframe
            width="1150"
            height="450"
            src="https://datastudio.google.com/embed/reporting/d369f04b-d4e9-4587-92d3-9f2f9f644e9e/page/NT64B"
            frameborder="0"
            style="border: 0"
            allowfullscreen
          ></iframe>
        </el-col>
      </el-row>
    </el-card>
    <br />
  </div>
</template>


<script>
export default {
  data() {
    return {
      bulkRNA: [],
      scRNA: [],
      immuneCellNum: [],
    };
  },
  created() {
    this.getbulkRNA();
    this.getscRNA();
    this.getimcellnum();
  },
  methods: {
    getbulkRNA() {
      this.$http.get("/tiger/bulkRNAinfo.json").then((res) => {
        this.bulkRNA = res.data;
        this.draw_bulk_chart(this.bulkRNA, "bulkstat");
      });
    },
    getscRNA() {
      this.$http.get("/tiger/scRNAinfo.json").then((res) => {
        this.scRNA = res.data;
        this.draw_sc_chart(this.scRNA, "scstat_cell", "cell");
        this.draw_sc_chart(this.scRNA, "scstat_sample", "sample");
      });
    },
    getimcellnum() {
      this.$http.get("/tiger/cellnum_stat.json").then((res) => {
        this.immuneCellNum = res.data;
        console.log(this.immuneCellNum);
        this.draw_imcell_chart(this.immuneCellNum, "immunecellstat");
      });
    },
    draw_bulk_chart(data, id) {
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      // sort the data
      data = data
        // .filter((item) => item["Cancertype"] !== "Total")
        .sort(function (a, b) {
          return a["Response"] - b["Response"];
        });
      var ydata = data.map((item) => item["Cancertype"]); // get ylab name
      // console.log(data);
      let myChart_mercor = window.echarts.init(targetdiv);
      let option = {
        tooltip: {
          trigger: "axis",
          axisPointer: {
            // Use axis to trigger tooltip
            type: "shadow", // 'shadow' as default; can also be 'line' or 'shadow'
          },
        },
        legend: {
          data: ["Response", "Non-response", "Unkown-response"],
          textStyle: {
            fontSize: 12,
            fontWeight: "bold",
          },
        },
        grid: {
          left: "3%",
          right: "15%",
          bottom: "0%",
          top: "10%",
          containLabel: true,
        },
        xAxis: {
          type: "value",
          axisLabel: {
            rotate: 30,
            margin: 10,
            fontSize: 12,
            fontWeight: "bold",
          },
        },
        yAxis: {
          type: "category",
          data: ydata,
          axisLabel: {
            rotate: 0,
            interval: 0,
            margin: 10,
            fontSize: 12,
            fontWeight: "bold",
          },
        },
        series: [
          {
            name: "Response",
            type: "bar",
            stack: "total",
            label: {
              show: true,
            },
            emphasis: {
              focus: "series",
            },
            data: data.map((item) => item["Response"]),
          },
          {
            name: "Non-response",
            type: "bar",
            stack: "total",
            emphasis: {
              focus: "series",
            },
            data: data.map((item) => item["Non-response"]),
          },
          {
            name: "Unkown-response",
            type: "bar",
            stack: "total",
            emphasis: {
              focus: "series",
            },
            data: data.map((item) => item["Unkown-response"]),
          },
        ],
      };
      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },

    draw_sc_chart(data, id, suffix) {
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      // sort the data
      var xdata1_key = "no_ICB_" + suffix;
      var xdata2_key = "ICB_" + suffix;
      data = data
        // .filter((item) => item["Cancertype"] !== "Total")
        .sort(function (a, b) {
          return a[xdata1_key] + a[xdata2_key] - b[xdata1_key] - b[xdata2_key];
        });
      var ydata = data.map((item) => item["Cancertype"]); // get ylab name
      // console.log(ydata);
      let myChart_mercor = window.echarts.init(targetdiv);
      let option = {
        tooltip: {
          trigger: "axis",
          axisPointer: {
            // Use axis to trigger tooltip
            type: "shadow", // 'shadow' as default; can also be 'line' or 'shadow'
          },
        },
        legend: {
          data: ["No-ICB", "ICB"],
          textStyle: {
            fontSize: 12,
            fontWeight: "bold",
          },
          tooltip: {
            show: true,
            formatter: "Immune checkpoint blockade (ICB)",
          },
        },
        grid: {
          left: "3%",
          right: "15%",
          bottom: "0%",
          top: "10%",
          containLabel: true,
        },
        xAxis: {
          type: "value",
          axisLabel: {
            rotate: 30,
            interval: 2,
            margin: 10,
            fontSize: 12,
            fontWeight: "bold",
          },
        },
        yAxis: {
          type: "category",
          data: ydata,
          axisLabel: {
            rotate: 0,
            interval: 0,
            margin: 10,
            fontSize: 12,
            fontWeight: "bold",
          },
        },
        series: [
          {
            name: "No-ICB",
            type: "bar",
            stack: "total",
            // label: {
            //   show: true,
            // },
            emphasis: {
              focus: "series",
            },
            data: data.map((item) => item[xdata1_key]),
          },
          {
            name: "ICB",
            type: "bar",
            stack: "total",
            emphasis: {
              focus: "series",
            },
            data: data.map((item) => item[xdata2_key]),
          },
        ],
      };
      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },

    draw_imcell_chart(data, id) {
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      // sort the data
      data = data.filter((item) => item["GlobelCluster"] !== "All");
      // .sort(function (a, b) {
      //   return a["Response"] - b["Response"];
      // });
      var ydata = data.map((item) => item["GlobelCluster"]); // get ylab name
      var legenddata = Object.keys(data[0]).filter(
        (item) => item !== "GlobelCluster"
      );
      var seriesList = [];

      seriesList = legenddata.map((cancertype) => {
        var seriesObject = {};
        seriesObject.name = cancertype;
        seriesObject.type = "bar";
        seriesObject.stack = "total";
        seriesObject.emphasis = { focus: "series" };
        seriesObject.data = data.map((item) => item[cancertype]);
        return seriesObject;
      });
      // console.log(data);
      let myChart_mercor = window.echarts.init(targetdiv);
      let option = {
        tooltip: {
          trigger: "axis",
          axisPointer: {
            // Use axis to trigger tooltip
            type: "shadow", // 'shadow' as default; can also be 'line' or 'shadow'
          },
        },
        legend: {
          data: legenddata,
          textStyle: {
            fontSize: 12,
            fontWeight: "bold",
          },
          orient: "vertical",
          x: "right", //可设定图例在左、右、居中
          y: "center", //可设定图例在上、下、居中
          padding: [0, 50, 0, 200], //可设定图例[距上方距离，距右方距离，距下方距离，距左方距离]
        },
        grid: {
          left: "3%",
          right: "60%",
          bottom: "0%",
          top: "0%",
          containLabel: true,
        },
        xAxis: {
          type: "value",
          axisLabel: {
            rotate: 30,
            margin: 10,
            fontSize: 12,
            fontWeight: "bold",
          },
        },
        yAxis: {
          type: "category",
          data: ydata,
          axisLabel: {
            rotate: 0,
            interval: 0,
            margin: 10,
            fontSize: 12,
            fontWeight: "bold",
          },
        },

        series: seriesList,
      };
      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
  },
  components: {},
};
</script>

<style>
.title {
  color: rgb(20, 146, 140);
  font-size: 30px;
}
.el-row {
  margin-top: 30px;
  margin-bottom: 20px;
}
.el-col {
  border-radius: 20px;
}
</style>
