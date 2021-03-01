<template>
  <div class="textitem">
    <el-card>
      <div>
        <el-row v-loading="singleCellCorloading">
          <el-table
            :data="sccoexpTable"
            max-height="600"
            style="width: 100%"
            :row-key="getRowKeys"
            :expand-row-keys="expands"
            @expand-change="diffExpRespontableExpand"
          >
            <template slot="empty">
              <p class="imgtilte">This gene is not express in the selected cell type</p>
            </template>
            <el-table-column type="expand">
              <template slot-scope="props">
                <div class="detailimg" v-loading="picScatterloading">
                  <el-row justify="center">
                    <el-col span="4" push="2">
                      <el-collapse>
                        <el-collapse-item title="Optional" name="1">
                          <template slot="title">
                            Optional
                            <i class="el-icon-setting"></i>
                          </template>
                          <el-row class="detail1"
                            >Correlation Coefficient</el-row
                          >
                          <el-row>
                            <el-radio v-model="corMed" label="pearson"
                              >Pearson</el-radio
                            >
                            <el-radio v-model="corMed" label="spearman"
                              >Spearman</el-radio
                            >
                          </el-row>
                          <el-row class="detail1"
                            >Delete Cells Not Express</el-row
                          >
                          <el-row>
                            <el-radio v-model="delzero" label="1">Yes</el-radio>
                            <el-radio v-model="delzero" label="0">No</el-radio>
                          </el-row>
                          <br />
                          <el-row class="plot">
                            <el-button
                              id="anabt"
                              @click="clickPlot()"
                              style="width: 100%"
                              >Plot</el-button
                            >
                          </el-row>
                        </el-collapse-item>
                      </el-collapse>
                    </el-col>
                    <el-col span="12" push="2">
                      <img
                        width="300px"
                        :src="picScatter"
                        v-show="detailimgShow"
                      />
                    </el-col>
                  </el-row>
                  <div v-show="!detailimgShow">no result</div>
                </div>
              </template>
            </el-table-column>
            <el-table-column
              prop="datasetid"
              label="DatasetID"
            ></el-table-column>
            <el-table-column
              prop="GlobalCluster"
              label="Main Lineage"
            ></el-table-column>
            <el-table-column
              prop="CellType"
              label="Cell Type"
            ></el-table-column>
            <el-table-column
              prop="genea"
              label="Search Gene"
              width="180"
            ></el-table-column>
            <el-table-column
              prop="geneb"
              label="Correlated Gene"
              width="180"
            ></el-table-column>
            <el-table-column label="COR" prop="r" sortable></el-table-column>
            <!-- <el-table-column prop="COEAID" label="COEAID"></el-table-column> -->
            <!-- <el-table-column prop="SCID" label="SCID"></el-table-column> -->
          </el-table>
        </el-row>
        <!-- <br />
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
        </el-row> -->
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
      sccoexpTable: [],
      picScattername: "",
      picScatterloading: true,
      corMed: "spearman",
      delzero: "0",
      imgparam: [],
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
      this.sccoexpTable = [];
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
    picScatterPlot(datasetid, GlobalCluster, genea, geneb, CellType) {
      // console.log(datasetid, GlobalCluster, genea, geneb, CellType);
      var that = this;
      that.detailimgShow = true;

      that.picScatterloading = true;
      var params = {
        cancer: datasetid,
        gloclu: GlobalCluster,
        gene: genea,
        clickgene: geneb,
        cluster: CellType,
        method: this.corMed,
        delzero: this.delzero,
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
        this.imgparam.CellType
      );
    },
    getDiagramData(
      gene,
      id,
      datasetid,
      gloclu,
      celltype,
      currentPage,
      pageSize
    ) {
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

    getRowKeys: function (row) {
      return row.geneb;
    },
    diffExpRespontableExpand: function (row, expandedRows) {
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
