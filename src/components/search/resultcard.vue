<template>
  <div>
    <div class="textitem">
      <div class="tablewidth" v-loading="cardLoading">
        <el-card v-show="diffExpResponShow">
          <p class="card-title">{{title}}</p>
          <el-row v-loading="diffExpResponloading">
            <div :id="conditi" class="scaterPlot" style="width: 1000px;height:400px;"></div>
            <el-table
              max-height="520"
              :data="diffExpRespontableData"
              :row-key="getRowKeys"
              :expand-row-keys="expands"
              @expand-change="rowExpand"
              @sort-change="sortChangeClick"
              style="width: 100%"
            >
              <el-table-column type="expand" >
                <template slot-scope="scope">
                  <div class="detailimg" v-loading="loading">
                    <img width="300px" :src="imgUrlBox" v-show="detailimgShow" />
                    <div v-show="!detailimgShow">no result</div>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="CancerType" label="Cancer Type" width="120%"></el-table-column>
              <el-table-column prop="Therapy" label="Immunotherapy Type" ></el-table-column>
              <el-table-column label="Gene Symbol">{{seargene}}</el-table-column>
              <el-table-column prop="DatasetID" label="Dataset"></el-table-column>
              <el-table-column prop="PMID" label="PMID" width="100%">
                <template slot-scope="scope">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                    target="_blank"
                    class="buttonText">{{scope.row.PMID}}</a>
                </template>
              </el-table-column>
              <el-table-column v-if="conditi === 'Responder'" prop="ResponseSampleCount" label="Responder Number"></el-table-column>
              <el-table-column v-if="conditi === 'Responder'" prop="NonresponseSampleCount" label="Non-responder Number"></el-table-column>
              <el-table-column v-if="conditi === 'Therapy'" prop="PretherapySampleCount" label="Pre-therapy Sample Number"></el-table-column>
              <el-table-column v-if="conditi === 'Therapy'" prop="PosttherapySampleCount" label="Post-therapy Sample Number"></el-table-column>
              <el-table-column v-if="conditi === 'Survival'" prop="ZScore" label="Hazard Ratio" sortable="custom"></el-table-column>
              <el-table-column v-else prop="Log2FC" label="Log2 Fold Change" sortable="custom"></el-table-column>
              <el-table-column v-if="conditi === 'Survival'" prop="PValue" label="-log10 (P Value)" sortable="custom"></el-table-column>
              <el-table-column v-else prop="PValue" label="-log10 (P Value)" sortable="custom"></el-table-column>
            </el-table>
          </el-row>
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
              layout="sizes,prev, pager, next"
              :total="total"
            ></el-pagination>
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
      currentPage: 1,
      pageSize: 20,
      total: 200,
      sortCol: "",
      sortOrder: "",
    };
  },

  computed: {
    imgUrlBox: function () {
      return "tiger/img/" + this.imgpathBox + ".png";
    }
  },

  mounted() {
    this.$nextTick(() => {
      this.getTableData(
        this.seargene,
        this.conditi,
        this.currentPage,
        this.pageSize,
        this.sortCol,
        this.sortOrder,
        true
      );
    });
  },

  methods: {
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
      // this.loadpage = 1;
      console.log(column.prop + column.order)
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
    getRowKeys: function (row) {
      return row.DatasetID;
    },
    rowExpand: function (row, expandedRows) {
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

    getTableData(gene, conditi, currentPage, pageSize, sortCol, sortOrder, ifplot){
      this.diffExpRespontableData = [];
      this.cardLoading = true;
      this.$http
        .get("/tiger/homeresponse.php", {
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
            this.cardLoading = false;
            // console.log( res.data.datatable)
            this.total = res.data.total[0];
            this.diffExpRespontableData = res.data.datatable;
            if (ifplot === true) this.draw_chart(res.data.list) 
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
      myChart_mercor.clear();
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
              return xlabname + params.data[0] + "<br />P: " + params.data[1] + "<br />Dataset: " + params.data[2]
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
.scPagination.el-pagination.is-background {
  text-align: center;
}

</style>
