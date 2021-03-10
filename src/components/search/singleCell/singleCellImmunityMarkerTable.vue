<template>
  <div class="textitem">
    <p class="card-title">{{ title }}</p>
    <el-row>
      <el-col :span="20" :push="2" v-loading="loading">
        <div :id="conditi" style="width: 1200px; height: 600px"></div>
      </el-col>
    </el-row>
    <el-table
      max-height="600"
      :data="TableData"
      :row-key="getRowKeys"
      :expand-row-keys="expands"
      @expand-change="rowExpand"
      @sort-change="sortChangeClick"
      style="width: 100%"
    >
      <el-table-column type="expand">
        <template slot-scope="scope">
          <div class="detailimg" v-loading="imgloading">
            <div>
              <!-- <img id="singleimg" :src="imgpathBox" />
              <img id="singleimg" :src="imgUrlBar" /> -->
              <el-row v-show="imgshow" class="scdetailimg">
                <!-- <p class="card-title">tSNE</p> -->
                <el-col
                  :span="6"
                  style="position: relative; left: 20px; top: 0px"
                >
                  <p class="imgtitle">Cell Types Distribution</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + overviewimg.split(',')[0] + '.png'"
                    @click="
                      previewImg(0, [
                        'tiger/img/' + overviewimg.split(',')[0] + '.png',
                        'tiger/img/' + markerimg.split(',')[1],
                        'tiger/img/' + markerimg.split(',')[0],
                      ])
                    "
                  />
                </el-col>
                <el-col
                  :span="6"
                  style="position: relative; left: 100px; top: 0px"
                >
                  <p class="imgtitle">{{ seargene }} Expression</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + markerimg.split(',')[1]"
                    @click="
                      previewImg(1, [
                        'tiger/img/' + overviewimg.split(',')[0] + '.png',
                        'tiger/img/' + markerimg.split(',')[1],
                        'tiger/img/' + markerimg.split(',')[0],
                      ])
                    "
                  />
                </el-col>
                <el-col
                  :span="12"
                  style="position: relative; left: 40px; top: 0px"
                >
                  <p class="imgtitle">{{ seargene }} Expression Difference</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    height="250px"
                    :src="'tiger/img/' + markerimg.split(',')[0]"
                    @click="
                      previewImg(2, [
                        'tiger/img/' + overviewimg.split(',')[0] + '.png',
                        'tiger/img/' + markerimg.split(',')[1],
                        'tiger/img/' + markerimg.split(',')[0],
                      ])
                    "
                  />
                </el-col>
              </el-row>
            </div>
            <div v-show="!imgshow">no result</div>
          </div>
        </template>
      </el-table-column>
      <el-table-column
        prop="CancerType"
        label="Cancer Type"
        width="400%"
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="datasetid"
        label="Dataset ID"
        width="120%"
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="GlobalCluster"
        label="Main Lineage"
        width="180%"
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="CellType"
        label="Cell Type"
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="Log2FoldChange"
        label="Log2 ( Fold Change )"
        sortable="custom"
      ></el-table-column>
    </el-table>
    <el-row>
      <el-pagination
        class="scPagination"
        background
        :page-sizes="[10, 20, 50, 100]"
        :page-size="pageSize"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        layout="sizes, prev, pager, next"
        :total="total"
      ></el-pagination>
    </el-row>
  </div>
</template>

<script>
export default {
  props: {
    seargene: String,
    conditi: String,
    title: String,
  },
  data() {
    return {
      expands: [],
      imgshow: true,
      loading: true,
      currentPage: 1,
      pageSize: 10,
      total: 200,
      TableData: [],
      imgparam: [],
      sortCol: "",
      sortOrder: "",
      imgparam: {},
      markerimg: "",
      overviewimg: "",
      imgpath: "",
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.getTableData(
        this.seargene,
        this.conditi,
        this.currentPage,
        this.pageSize,
        this.sortCol,
        this.sortOrder,
        true
      );
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
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.getTableData(
          this.seargene,
          this.conditi,
          this.currentPage,
          this.pageSize,
          this.sortCol,
          this.sortOrder,
          true
        );
      }
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1;
      this.getTableData(
        this.seargene,
        this.conditi,
        this.currentPage,
        this.pageSize,
        this.sortCol,
        this.sortOrder,
        false
      );
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.getTableData(
        this.seargene,
        this.conditi,
        this.currentPage,
        this.pageSize,
        this.sortCol,
        this.sortOrder,
        false
      );
    },
    sortChangeClick(column) {
      // this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.currentPage = 1;
      // console.log(column.prop + column.order);
      this.getTableData(
        this.seargene,
        this.conditi,
        this.currentPage,
        this.pageSize,
        this.sortCol,
        this.sortOrder,
        false
      );
    },
    getTableData(
      gene,
      conditi,
      currentPage,
      pageSize,
      sortCol,
      sortOrder,
      ifplot
    ) {
      this.show = true;
      this.imgshow = false;
      this.diffexpimg = "";
      this.loading = true;
      this.$http
        .get("/tiger/searchData.php", {
          params: {
            gene: gene,
            conditi: conditi,
            currentPage: currentPage,
            pageSize: pageSize,
            sortcol: sortCol,
            sortorder: sortOrder === null ? "None" : sortOrder,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            if (res.data.list.length === 0) {
              this.show = false;
            } else {
              this.loading = false;
              this.TableData = res.data.datatable;
              this.total = res.data.total[0];
              if (ifplot) this.draw_chart(res.data.list, conditi);
            }
          } else {
            this.show = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    expandPlot(cancer, gloclu, subClu) {
      var that = this;
      that.imgloading = true;
      that.imgshow = true;

      this.$http
        .get("/tiger/scimmudiffexpdetailgene.php", {
          params: {
            cancer: cancer,
            gene: that.seargene,
            type: "celltype",
            gloclu: gloclu,
            celltype: subClu,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            if (res.data.output[0] === "0") {
              that.imgshow = false;
              //alert("no gene file");
            } else {
              that.imgpathBox = "tiger/img/" + res.data.output[0].split(",")[0];
              // console.log(that.imgpathBox)
              that.markerimg = res.data.output[0];
            }
            that.imgloading = false;
          }
          if (res.data.status2 == 0) {
            if (res.data.output2[0] === "0") {
              //that.evolushow2 = false;
              //alert("no gene file");
            } else {
              // that.evolushow2 = true;
              that.overviewimg = res.data.output2[0];
            }
            //that.evoluplots = res.data.output[0];
          }
          that.imgshow = true;
        })
        .catch(function (res) {
          console.log(res);
        });
    },
    getRowKeys: function (row) {
      return (row.datasetid + row.GlobalCluster + row.CellType).replace(
        /\ /g,
        "_"
      );
    },
    rowExpand: function (row, expandedRows) {
      if (expandedRows.length) {
        this.expands = [];
        if (row) {
          this.expands.push(
            (row.datasetid + row.GlobalCluster + row.CellType).replace(
              /\ /g,
              "_"
            )
          );
        }
      } else {
        this.expands = [];
      }
      // console.log(that.expands_tn)

      this.expandPlot(row.datasetid, row.GlobalCluster, row.CellType);
    },

    draw_chart(data, id) {
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);
      myChart_mercor.clear();
      var max = data.reduce(function (a, b) {
        return b[0] > a[0] ? b[0] : a[0];
      });
      // console.log(max)
      var option = {
        title: {
          text: "Cell Type Marker\n ( |Log2FC| )\n",
          left: "20%",
          textStyle: {
            color: "#333",
            lineHeight: 120,
            height: 30,
            fontFamily: "Arial",
          },
        },
        legend: {
          data: ["Punch Card"],
          left: "right",
        },
        polar: {
          radius: "70%",
          center: ["50%", "50%"],
        },
        radiusAxis: {
          type: "value",
          axisLine: {
            show: true,
          },
          axisLabel: {
            rotate: 45,
            interval: 0,
          },
        },
        angleAxis: {
          type: "category",
          // data: unique(cancer),
          boundaryGap: false,
          startAngle: 20,
          splitLine: {
            show: true,
            lineStyle: {
              color: "#999",
              type: "dashed",
            },
          },
          axisLabel: {
            interval: 0,
            margin: 20,
            formatter: function (value, index) {
              var reg = /[, ]/g;
              value = value.replace(reg, "\n");
              return value;
            },
          },
        },
        series: [
          {
            name: "Cell Type Marker",
            type: "scatter",
            coordinateSystem: "polar",
            large: true,
            data: data,
            symbolSize: function (val) {
              return 25/max * val[0];
            },
            animation: false,
            emphasis: {
              label: {
                borderWidth: 1.5,
                show: true,
                position: "right",
                distance: 10,
                color: "rgba(255, 255, 255, 1)",
                fontStyle: "normal",
                fontWeight: "bold",
                fontFamily: "Arial",
                fontSize: 15,
                align: "left",
                verticalAlign: "middle",
                backgroundColor: "rgba(50, 50, 50, 0.8)",
                borderColor: "rgba(0, 0, 0, 1)",
                padding: [9, 9, 9, 9],
                borderRadius: [5, 5, 5, 5],
                lineHeight: 25,
                formatter:
                  "CancerType: {@[1]}\nCellType: {@[2]}\nLog2FC: {@[3]}",
              },
            },
          },
        ],
      };
      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },

    previewImg(index, url) {
      this.$hevueImgPreview({
        imgList: url,
        multiple: true, // 开启多图预览模式
        keyboard: true,
        nowImgIndex: index, // 多图预览，默认展示第二张图片
        mainBackground: "rgba(0, 0, 0, .5)", // 整体背景颜色
        closeColor: "rgba(255,255,255,.5)",
      });
    },
    clickPlot() {
      this.expandPlot(
        this.imgparam.datasetid,
        this.imgparam.GlobalCluster,
        this.imgparam.CellType
      );
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
