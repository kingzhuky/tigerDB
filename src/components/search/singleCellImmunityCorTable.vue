<template>
  <div class="textitem">
    <el-card>
      <div>
        <el-row v-loading="singleCellCorloading">
          <el-table
            :data="ReactomeTableData"
            max-height="800"
            style="width: 100%"
            :row-key="getRowKeys"
            :expand-row-keys="expands"
            @expand-change="diffExpRespontableExpand"
          >
            <el-table-column type="expand">
              <template slot-scope="props">
                <div class="detailimg" v-loading="picScatterloading">
                  <img width="450px" :src="picScatter" v-show="detailimgShow" />
                  <div v-show="!detailimgShow">no result</div>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="datasetid" label="DatasetID"></el-table-column>
            <el-table-column prop="GlobalCluster" label="Global Cluster"></el-table-column>
            <el-table-column prop="CellType" label="Cell Type"></el-table-column>
            <el-table-column prop="genea" label="Search Gene" width="180"></el-table-column>
            <el-table-column prop="geneb" label="Correlated Gene" width="180"></el-table-column>
            <el-table-column label="COR" prop="r"></el-table-column>
            <!-- <el-table-column prop="COEAID" label="COEAID"></el-table-column> -->
            <!-- <el-table-column prop="SCID" label="SCID"></el-table-column> -->
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
      </div>
    </el-card>
  </div>
</template>

<script>
export default {
  props: {
    seargene: String,
    GlobalCluster: String,
    CellType: String,
    CancerType: String,
  },
  data() {
    return {
      expands: [],
      detailimgShow: true,
      currentPage: 1,
      pageSize: 20,
      total: 200,
      CellTypeLoading: false,
      loading: false,
      ReactomeTableData: [],
      picScattername: "",
      picScatterloading: true,
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
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
      this.ReactomeTableData = [];
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1;
      this.getDiagramData(this.seargene, "singleCellCorTumor", 1, val);
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        val,
        this.pageSize
      );
    },
    picScatterPlot(datasetid, GlobalCluster, genea, geneb, CellType) {
      console.log(datasetid, GlobalCluster, genea, geneb, CellType);
      var that = this;
      that.detailimgShow = true;

      that.picScatterloading = true;
      var params = {
        cancer: datasetid,
        gloclu: GlobalCluster,
        gene: genea,
        clickgene: geneb,
        cluster: CellType,
        method: "spearman",
      };
      this.$http
        .get("/tiger/scimmucoexpdetail.php", {
          params: params,
        })
        .then(function (res) {
          if (res.data.status == 0) {
            that.picScattername = res.data.output[0];
            that.picScatterloading = false;
          } else {
            that.detailimgShow = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.clickPlot();
        this.getScaData(
          this.seargene,
          "home_scdiffexp_tn",
          "singleCellImmuTumor"
        );
        this.getScaData(
          this.seargene,
          "home_scdiffexp_rnr",
          "singleCellImmuResponse"
        );
      }
    },
    clickPlot() {
      this.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        this.currentPage,
        this.pageSize
      );
    },
    getDiagramData(gene, id, currentPage, pageSize) {
      this.ReactomeTableData = [];
      this.singleCellCorloading = true;
      this.$http
        .get("/tiger/searchcoeaTable.php", {
          params: {
            gene: gene,
            currentPage: currentPage,
            pageSize: pageSize,
            GlobalCluster: this.GlobalCluster,
            CellType: this.CellType,
            CancerType: this.CancerType,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.ReactomeTableData = res.data.list;
            this.total = res.data.total[0];
            this.singleCellCorloading = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    getRowKeys: function (row) {
      return row.geneb;
    },
    diffExpRespontableExpand: function (row, expandedRows) {
      var that = this;
      if (expandedRows.length) {
        that.expands = [];
        if (row) {
          that.expands.push(row.geneb);
        }
      } else {
        that.expands = [];
      }

      this.picScatterPlot(
        row.datasetid,
        row.GlobalCluster,
        row.genea,
        row.geneb,
        row.CellType
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
