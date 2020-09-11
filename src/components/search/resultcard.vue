<template>
  <div>
    <div class="textitem">
      <div class="tablewidth" v-loading="cardLoading">
        <el-card v-show="diffExpResponShow">
          <p class="card-title">{{title}}</p>
          <el-row v-loading="diffExpResponloading">
            <div :id="conditi" class="scaterPlot" style="width: 600px;height:400px;"></div>
            <el-table
              max-height="800"
              :data="diffExpRespontableData"
              :row-key="getRowKeys"
              :expand-row-keys="expands"
              @expand-change="diffExpRespontableExpand"
              style="width: 100%"
            >
              <el-table-column type="expand">
                <template slot-scope="props">
                  <div class="detailimg" v-loading="loading">
                    <img width="450px" :src="imgUrlBox" v-show="detailimgShow" />
                    <div v-show="!detailimgShow">no result</div>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="DatasetID" label="Dataset"></el-table-column>
              <el-table-column prop="CancerType" label="Cancer Type"></el-table-column>
              <el-table-column prop="Therapy" label="Therapy"></el-table-column>
              <el-table-column prop="ResponseSampleCount" label="Responder Number(PR,CR)"></el-table-column>
              <el-table-column prop="NonresponseSampleCount" label="Non-responder Number(PD, SD)"></el-table-column>
            </el-table>
          </el-row>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    conditi: {type: String},
    title: {type: String},
    seargene: {type: String}
  },

  data() {
    return {
      expands: [],
      diffExpResponShow: true,
      cardLoading: true,
      diffExpResponloading: false,
      diffExpRespontableData: [],
      loading: false,
      imgpathBox: "",
      getPlotUrl: "",
      detailimgShow: true,
    };
  },

  computed: {
    imgUrlBox: function () {
      return "tiger/img/" + this.imgpathBox + ".png";
    }
  },

  mounted() {
    this.$nextTick(() => {
      this.getTableData(this.seargene, this.conditi);
    });
  },

  methods: {
    getRowKeys: function (row) {
      return row.DatasetID;
    },
    diffExpRespontableExpand: function (row, expandedRows) {
      var that = this;
      if (expandedRows.length) {
        that.expands = [];
        if (row) {
          that.expands.push(row.DatasetID);
        }
      } else {
        that.expands = [];
      }

      this.getPlot(this.seargene, row.DatasetID);
    },

    getPlot(gene, mergedatasets) {
      let getPlotUrl = "";
      let params = {};
      if (this.conditi === "Responder") {
        getPlotUrl = "/tiger/1.1.responseDiff.php";
        params = {
          gene: gene,
          mergedatasets: mergedatasets,
          responder: "CR,PR",
          noresponder: "PD,SD",
          normalMed: "None",
          normalGene: "None",
          logScale: "FALSE",
          datatype: "png",
        };
      } else if (this.conditi === "Therapy") {
        getPlotUrl = "/tiger/1.2.responseDiffTherapy.php";
        params = {
          gene: gene,
          mergedatasets: mergedatasets,
          normalMed: "None",
          normalGene: "None",
          logScale: "FALSE",
          datatype: "png",
        };
      } else {
        getPlotUrl = "/tiger/1.3.responseSur.php";
        params = {
          gene: gene,
          mergedatasets: mergedatasets,
          expcutoff: "0.5",
          normalMed: "None",
          normalGene: "None",
          datatype: "png",
        };
      }

      var that = this;
      this.detailimgShow = true;

      that.loading = true;

      this.$http
        .get(getPlotUrl, {
          params: params,
        })
        .then(function (res) {
          if (res.data.status == 0) {
            var imgpath = ""
            if (that.conditi === "Survival") {
              imgpath = res.data.output[2].split(",");
            } else {
              imgpath = res.data.output[0].split(",");
            }
            setTimeout((that.imgpathBox = imgpath[0]), 1000);
            that.loading = false;
          } else {
            this.detailimgShow = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    getTableData(gene, conditi) {
      var targetdiv = document.getElementById(this.conditi);
      let myChart_mercor = window.echarts.init(targetdiv);
      myChart_mercor.clear();
      this.diffExpRespontableData = [];
      this.cardLoading = true;
      this.$http
        .get("/tiger/homeresponse.php", {
          params: {
            gene: gene,
            conditi: conditi,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.cardLoading = false;
            this.diffExpRespontableData = res.data.datatable;
            this.draw_chart(res.data.list);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    diffExpResponClick() {},
    draw_chart(data) {
      var targetdiv = document.getElementById(this.conditi);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);
      var xAxis = "";
      if (this.conditi === "Survival") {
        xAxis = "ZScore";
      } else {
        xAxis = "LogFC";
      }

      let option = {
        xAxis: {
          name: xAxis,
          offset: 0,
        },
        yAxis: { name: "–log10(pvalue)" },
        tooltip: {
          formatter: "{c}",
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
</style>
