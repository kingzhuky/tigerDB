<template>
  <div class="textitem" v-show="show" v-loading="loading">
    <p class="card-title">{{title}}</p>
    <div class="geneExp">
      <div id="expscatter" class="scaterPlot" style="width: 800px;height:400px;"></div>
    </div>
      <el-table
          max-height="600"
          :data="TableData"
          :row-key="getRowKeys"
          :expand-row-keys="expands"
          @expand-change="diffExptableExpand"
          style="width: 100%"
        >
        <el-table-column type="expand" >
          <template slot-scope="scope">
            <div class="detailimg" v-loading="imgloading">
              <el-row class="scdetailimg" v-show="imgshow" >
                <el-col :span="6" >
                  <p class="imgtitle">Cell Types</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + diffexpimg.split(',')[0] + '.png'"
                    @click="previewImg(['tiger/img/' + diffexpimg.split(',')[0] + '.png','tiger/img/' + diffexpimg.split(',')[1] + '.png','tiger/img/' + diffexpimg.split(',')[2] + '.png'])">
                </el-col>
                <el-col :span="6" >
                  <p class="imgtitle">Cell Types</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + diffexpimg.split(',')[1] + '.png'"
                    @click="previewImg(['tiger/img/' + diffexpimg.split(',')[0] + '.png','tiger/img/' + diffexpimg.split(',')[1] + '.png','tiger/img/' + diffexpimg.split(',')[2] + '.png'])">
                </el-col>
                <el-col :span="6">
                  <p class="imgtitle">UMAP Plot of {{seargene}} Expression</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + diffexpimg.split(',')[2] + '.png'"
                    @click="previewImg(['tiger/img/' + diffexpimg.split(',')[0] + '.png','tiger/img/' + diffexpimg.split(',')[1] + '.png','tiger/img/' + diffexpimg.split(',')[2] + '.png'])">
                </el-col>
                <el-col :span="6">
                  <div class="imgspan"> 
                  <p class="imgtitle">Boxplot of {{seargene}} Expression</p>
                    <img
                    id="singleimg"
                    fit="fill"
                    height="250px"
                    :src="'tiger/img/' + diffexpimg.split(',')[3] + '.png'"
                    @click="previewImg(['tiger/img/' + diffexpimg.split(',')[0] + '.png','tiger/img/' + diffexpimg.split(',')[1] + '.png','tiger/img/' + diffexpimg.split(',')[2] + '.png'])">
                  </div>
                </el-col>
              </el-row> 
              <div v-show="!singleCellImmuTumorImgshow">no result</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="CancerType" label="Cancer Type" width="400%" sortable></el-table-column>
        <el-table-column prop="datasetid" label="Dataset ID" width="120%" sortable></el-table-column>
        <el-table-column prop="GlobalCluster" label="Global Cluster" sortable></el-table-column>
        <el-table-column prop="CellType" label="Cell Type" sortable></el-table-column>
        <el-table-column prop="Log2FoldChange" label="Log2 Fold Change" sortable></el-table-column>
        <el-table-column prop="P_Value" label="-log10 (P Value)" sortable></el-table-column>
      </el-table>
  </div>
</template>

<script>
export default {
  props: {
    gene: String,
    conditi: String,
    title: String,
  },
  data() {
    return {
      expands: [],
      imgshow: true,
      loading: true,
      currentPage: 1,
      pageSize: 20,
      total: 200,
      diffexpimg: "",
      TableData: [],
      imgparam: [],
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.getScaData(this.gene, this.conditi)
      //this.clickPlot();
    });
  },

  computed: {
    picScatter: function () {
      return "tiger/img/" + this.picScattername + ".png";
    },
  },

  methods: {
    reset() {
      this.TableData = [];
      this.diffexpimg = "";
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1;
      this.getDiagramData(
        this.seargene, 
        "singleCellCorTumor",
        this.CancerType,
        this.GlobalCluster,
        this.CellType,
        1,
        val
      );
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        this.CancerType,
        this.GlobalCluster,
        this.CellType,
        val,
        this.pageSize
      );
    },
    getScaData(gene, conditi) {
      this.show = true;
      this.imgshow = false;
      this.diffexpimg = "";
      this.loading = true;
      this.$http
        .get("/tiger/homeresponse.php", {
          params: {
            gene: gene,
            conditi: conditi,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            if (res.data.list.length === 0) {
              this.show = false;
            } else {
              this.draw_chart_sca(res.data.list, "expscatter");
              this.loading = false;
              this.TableData = res.data.infosTable;
            }
          } else {
            this.show = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.getDiagramData(
          this.seargene,
          "singleCellCorTumor",
          this.CancerType,
          this.GlobalCluster,
          this.CellType,
          this.currentPage,
          this.pageSize
        );
      }
    },
    clickPlot() {
      this.picScatterPlot(
        this.imgparam.datasetid,
        this.imgparam.GlobalCluster,
        this.imgparam.genea,
        this.imgparam.geneb,
        this.imgparam.CellType,
      );
    },
    getDiagramData(gene, datasetid, gloclu, celltype, currentPage, pageSize) {
      this.sccoexpTable = [];
      this.singleCellCorloading = true;
      this.$http
        .get("/tiger/searchcoeaTable.php", {
          params: {
            gene: gene,
            currentPage: currentPage,
            pageSize: 20,
            GlobalCluster: gloclu,
            CellType: celltype,
            CancerType: datasetid,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.sccoexpTable = res.data.list;
            this.total = res.data.total[0];
            this.singleCellCorloading = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    differentialExpressionPlot(cancer, gloclu, subClu) {
      var that = this;
      that.imgloading = true;
      that.imgshow = true;

      this.$http
        .get("/tiger/scimmudiffexpdetailgene.php", {
          params: {
            cancer: cancer,
            gene: this.seargene,
            type: "exp",
            gloclu: gloclu,
            celltype: subClu,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            if (res.data.output[0] === "0") {
              that.imgshow = false;
            } else {
              that.imgshow = true;
              that.imgloading = false;
              that.imgpathBar2 =
                "/tiger/img/" + res.data.output[0].split(",")[2] + '.png';
              that.diffexpimg = res.data.output[0];
              that.diffexpimg = res.data.output2[0].split(",")[0] + ',' + that.diffexpimg;
              console.log(that.diffexpimg)
            }
          } else {
            that.imgshow = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
    getRowKeys: function (row) {
      return (row.datasetid + row.GlobalCluster + row.CellType).replace(/\ /g,'_');
    },
    diffExptableExpand: function (row, expandedRows) {
      var that = this;
      if (expandedRows.length) {
        that.expands = [];
        if (row) {
          that.expands.push(row.geneb);
          that.imgparam = row;
        }
      } else {
        that.expands = [];
        that.imgparam = [];
      }
      
      this.picScatterPlot(
        row.datasetid,
        row.GlobalCluster,
        row.genea,
        row.geneb,
        row.CellType,
      );
    },

    previewImg(url){
      this.$hevueImgPreview({
        url: url,
        multiple: false, // 开启多图预览模式
        keyboard: true,
        nowImgIndex: 0, // 多图预览，默认展示第二张图片
        mainBackground: 'rgba(0, 0, 0, .5)', // 整体背景颜色
      })
    },
    draw_chart_sca(data, id) {
      var that = this;
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        xAxis: { name: "Log2FC" },
        yAxis: {
          name: "–log10(P Value)",
          axisLine: { show: false },
          axisTick: { show: false },
        },
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

      // myChart_mercor.on("click", function (param) {
      //   if (param.componentSubType === "scatter") {
      //     //console.log(param.data);
      //     that.differentialExpressionPlot(
      //       param.data[2],
      //       param.data[3],
      //       param.data[4],
      //       id
      //     );
      //   }
      // });

      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
  },
};
</script>


<style>
.scPagination.el-pagination.is-background {
  text-align: center;
}

.detailimg {
  text-align: center;
}
</style>
