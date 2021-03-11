<template>
  <div class="textitem" v-show="show" v-loading="loading">
    <p class="card-title">{{ title }}</p>
    <div class="geneExp">
      <div
        :id="conditi"
        class="scaterPlot"
        style="width: 800px; height: 400px"
      ></div>
    </div>
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
            <el-row
              class="scdetailimg"
              v-show="imgshow"
              :gutter="20"
              type="flex"
              justify="space-around"
            >
              <el-col :span="4">
                <p class="imgtitle">Cell Types Distribution</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + diffexpimg.split(',')[0] + '.png'"
                  @click="
                    previewImg(0, [
                      'tiger/img/' + diffexpimg.split(',')[0] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[1] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[2] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[3] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[4] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col :span="4">
                <p class="imgtitle">Tissue Types Distribution</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + diffexpimg.split(',')[1] + '.png'"
                  @click="
                    previewImg(1, [
                      'tiger/img/' + diffexpimg.split(',')[0] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[1] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[2] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[3] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[4] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col :span="4">
                <div class="imgspan">
                  <p class="imgtitle">{{ seargene }} Expression</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + diffexpimg.split(',')[3] + '.png'"
                    @click="
                      previewImg(3, [
                        'tiger/img/' + diffexpimg.split(',')[0] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[1] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[2] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[3] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[4] + '.png',
                      ])
                    "
                  />
                </div>
              </el-col>
              <el-col :span="4">
                <p class="imgtitle">{{scope.row.CellType}} Cell Type Distribution Difference</p>
                <img
                  id="singleimg"
                  fit="fill"
                  width="100%"
                  :src="'tiger/img/' + diffexpimg.split(',')[2] + '.png'"
                  @click="
                    previewImg(2, [
                      'tiger/img/' + diffexpimg.split(',')[0] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[1] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[2] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[3] + '.png',
                      'tiger/img/' + diffexpimg.split(',')[4] + '.png',
                    ])
                  "
                />
              </el-col>
              <el-col :span="4">
                <div class="imgspan">
                  <p class="imgtitle">{{ seargene }} Expression Difference</p>
                  <img
                    id="singleimg"
                    fit="fill"
                    width="100%"
                    :src="'tiger/img/' + diffexpimg.split(',')[4] + '.png'"
                    @click="
                      previewImg(4, [
                        'tiger/img/' + diffexpimg.split(',')[0] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[1] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[2] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[3] + '.png',
                        'tiger/img/' + diffexpimg.split(',')[4] + '.png',
                      ])
                    "
                  />
                </div>
              </el-col>
            </el-row>
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
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="CellType"
        label="Cell Type"
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="Log2FoldChange"
        label="Log2 Fold Change"
        sortable="custom"
      ></el-table-column>
      <el-table-column
        prop="P_Value"
        label="-log10 (P Value)"
        sortable="custom"
      ></el-table-column>
    </el-table>
    <br />
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
      diffexpimg: "",
      TableData: [],
      imgparam: [],
      sortCol: "",
      sortOrder: "",
      imgparam: {},
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
      // console.log(column.prop + column.order)
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
              // console.log("table:")
              // console.log(res.data.datatable)
              // console.log("plot:")
              // console.log(res.data.list)
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
              that.diffexpimg = res.data.output[0];
              that.diffexpimg =
                res.data.output2[0].split(",")[0] + "," + that.diffexpimg;
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
      let option = {
        xAxis: {
          name: "Log2 (Fold Change)",
          position: "bottom",
          nameLocation: "center",
          nameGap: 25,
          offset: 0,
          nameTextStyle: {
            fontSize: 18,
            fontWeight: "bold",
          },
        },
        yAxis: {
          name: "–log10(P Value)",
          axisLine: { show: false },
          axisTick: { show: false },
          position: "bottom",
          nameLocation: "center",
          nameGap: 25,
          offset: 10,
          nameTextStyle: {
            fontSize: 18,
            fontWeight: "bold",
          },
          axisLabel: {
            margin: -7,
          },
        },
        toolbox: {
          left: "center",
          feature: {
            dataZoom: {},
          },
        },
        dataZoom: [
          {
            type: "inside",
          },
          {
            type: "slider",
          },
          {
            type: "inside",
            orient: "vertical",
          },
          {
            type: "slider",
            orient: "vertical",
          },
        ],
        series: [
          {
            symbolSize: 20,
            data: data,
            type: "scatter",
            color: function (val) {
              return val.data[1] >= 1.3 ? "#b84040" : "#7d7d7d";
            },
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
                  "Log2FC: {@[0]}\n-log10(P Value): {@[1]}\nDataset ID: {@[2]}\nMain Lineage: {@[4]}",
              },
            },
          },
        ],
      };

      myChart_mercor.clear();
      myChart_mercor.setOption(option);

      // myChart_mercor.on("click", function (param) {
      //   if (param.componentSubType === "scatter") {
      //     console.log(param.data);
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
