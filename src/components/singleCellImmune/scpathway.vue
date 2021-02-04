<template>
  <div>
    <el-row>
      <el-tabs v-model="tabactiveName" @tab-click="handleClick" >
        <el-tab-pane label="Cluster" name="cluster" >
          <el-col :span="4" :offset="20"> 
            <el-autocomplete
              v-model="searchinput"
              placeholder="Please Input GSEA Name"
              @change="searchChange"
            ></el-autocomplete>
          </el-col>
          <br />
          <br />
          <br />
          <el-table
            class="tigtablele"
            id="scDiffExpTable"
            ref="singleTable"
            border
            max-height="750"
            :data="tableData"
            @cell-click="heandleclick"
            :cell-style="tableCellStyle"
            :header-cell-class-name="headerStyle"
            v-loadmore="tabelloadmore"
            v-loadlast="tableloadlast"
            v-loading="loading"
            @sort-change="sortChangeClick"
            style="100%"
          >
            <el-table-column
              v-for="(item,index) in tableDataheader"
              :key="index"
              :property="item.key"
              :label="item.name"
              :type="item.type"
              sortable="custom"
              align="center"
              width="80"
            ></el-table-column>
            <el-table-column property=" " label=" " align="center" width="120"></el-table-column>
          </el-table>
          <div class="colorbar">
            <span>Low NES&lt;0</span>
            <span class="heatMapTable--colorbar"></span>
            <span>High NES&gt;0</span>
          </div>
          <!-- 详细页显示与否 -->
          <v-scpathwaydetail2
            ref="pathwaydetailPlot"
            id="detailinfo"
            v-show="isShow"
            :pathway="clickGene"
            :celltype="celltype"
            :cancer="cancer"
            :gloclu="gloclu"
            :tabtype="tabactiveName"
          ></v-scpathwaydetail2>
        </el-tab-pane>
        <el-tab-pane label="Tumor VS Normal" name="diff">
            <el-col :span="4" :offset="20"> 
              <el-autocomplete
                v-model="searchinput"
                placeholder="Please Input GSEA Name"
                @change="searchChange"
              ></el-autocomplete>
            </el-col>
          <br />
          <br />
          <br />
          <el-table
            class="tigtablele"
            id="scDiffExpTable"
            ref="singleTable"
            border
            max-height="750"
            :data="tableData"
            @cell-click="heandleclick"
            :cell-style="tableCellStyle"
            :header-cell-class-name="headerStyle"
            v-loadmore="tabelloadmore"
            v-loadlast="tableloadlast"
            v-loading="loading"
            @sort-change="sortChangeClick"
            style="100%"
          >
            <el-table-column
              v-for="(item,index) in tableDataheader"
              :key="index"
              :property="item.key"
              :label="item.name"
              :type="item.type"
              sortable="custom"
              align="center"
              width="80"
            ></el-table-column>
            <el-table-column property=" " label=" " align="center" width="120"></el-table-column>
          </el-table>
          <div class="colorbar">
            <span>Low NES&lt;0</span>
            <span class="heatMapTable--colorbar"></span>
            <span>High NES&gt;0</span>
            
          </div>
          <!-- 详细页显示与否 -->
          <v-scpathwaydetail
            ref="pathwaydetailPlot"
            id="detailinfo2"
            v-show="isShow"
            :pathway="clickGene"
            :celltype="celltype"
            :cancer="cancer"
            :gloclu="gloclu"
            :tabtype="tabactiveName"
          ></v-scpathwaydetail>
        </el-tab-pane>
      </el-tabs>

    </el-row>

  </div>
</template>

<script>
import {
  scrollRow,
  toTargetbyid,
  gStyle,
  move,
  stop,
} from "../../../static/js/utils.js";

export default {
  props: {
    cancer: String,
    subClu: Array,
    subClucoptions: Array,
  },
  data() {
    return {
      clickGene: "",
      celltype:"",
      m6aMsg: {
        type: String,
      },
      cancerMsg: {
        type: String,
      },
      loading: true,
      isShow: false,
      loadpage: 1,
      tableData: [],
      searchinput: "",
      loadDir: "",
      sortCol: "",
      sortOrder: "",
      oldcancer: "",
      oldgloclu: "",
      tableDataheader: [],
      gloclu:"",
      whetherrnr:true,
      whetherdiff:true,
      tabactiveName: 'cluster',
    };
  },

  mounted: function () {
    this.oldcancer = this.cancer;
    this.oldgloclu = this.gloclu;
    this.getTableData(1, "", "");
  },

  watch: {
    loading() {
      switch (this.loading) {
        case true:
          stop();
          break;
        case false:
          move();
          break;
      }
    },
    clickGene(){
      this.$nextTick(() =>{
        toTargetbyid('#detailinfo');
        toTargetbyid('#detailinfo2');
      })
    }
  },

  methods: {
    handleClick(tab, event) {
      this.tabactiveName = tab.name;
      this.getTableData(1, "", "");
    },
    querySearchAsync(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.searchinput,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },
    headerStyle({ column }) {
      let cancer = column.type
      switch (cancer) {
        case "All":
          return "scglo-all";
        case "Tcell":
          return "scglo-g1";
        case "Myeloid":
          return "scglo-g2";
        case "Bcell":
          return "scglo-g3";
        case "CD4":
          return "scglo-g4";
        case "CD8":
          return "scglo-g5";
        case "gene":
          return "";
        default:
          return "defalutColor";
      }
    },
    plot() {
      // if (
      //   (this.oldcancer !== this.cancer) |
      //   (this.oldcancer === "") |
      //   (this.oldgloclu !== this.gloclu) |
      //   (this.oldgloclu === "")
      // ) {
        this.reset()
        this.oldcancer = this.cancer;
        this.oldgloclu = this.gloclu;
        this.getTableData(1, "", "");
      // }
    },

    sortChangeClick(column) {
      // console.log(column.prop, column.order);
      this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];

      this.getTableData(this.loadpage, column.prop, column.order);

    },

    //顶部加载更多
    tableloadlast() {
      this.loadDir = "up";
      if (this.loading == false && this.loadpage > 1) {
        this.loading = true;
        this.loadpage = this.loadpage - 1;
        this.getTableData(this.loadpage, this.sortCol, this.sortOrder);
        if (this.loadpage > 1) {
          // console.log(this.loadpage);
          scrollRow("scDiffExpTable", 400);
          this.loading = false;
        }
      }
    },

    //底部加载更多
    tabelloadmore() {
      this.loadDir = "down";
      if (this.loading == false) {
        this.loading = true;
        this.loadpage = this.loadpage + 1;
        this.getTableData(this.loadpage, this.sortCol, this.sortOrder);
        scrollRow("scDiffExpTable", 780);
      }
    },
    reset() {
      this.tableData = [];
      this.loadDir = "";
      this.tableDataheader = [];
    },

    //获取表格数据
    getTableData(page, sortCol, sortOrder) {
      this.loading = true
      var sqltable = ""
      if(this.tabactiveName === "cluster"){
        sqltable = "scgseacluster_"
      }else{
        sqltable = "scgseadiff_"
      }
      this.$http
        .get("/tiger/responseexpvs.php", {
          params: {
            type: sqltable + this.cancer ,
            draw: page,
            search: this.searchinput.trim(),
            start: (page - 1) * 20,
            length: 20,
            sortcol: sortCol,
            sortorder: sortOrder === null ? "None" : sortOrder,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.loading = false;
            if (this.loadDir === "down") {
              this.tableData = this.tableData.slice(
                this.tableData.length - 20,
                this.tableData.length
              );
              res.data.list.forEach((n) => {
                this.tableData.push(n);
              });
            } else if (this.loadDir === "up") {
              if (res.data.list.length !== 0) {
                let old = this.tableData.slice(0, 20);
                this.tableData = res.data.list;
                old.forEach((n) => {
                  this.tableData.push(n);
                });
              }
            } else {
              res.data.list.forEach((n) => {
                this.tableData.push(n);
              });
              this.tableDataheader = Object.keys(res.data.list[0]);
            }
            // console.log(Array.isArray(new_columns))
          }
            var new_columns = [] // generate header
            for (const column of this.tableDataheader) {
              var col_obj = {};
              col_obj.name = column.split(',').pop()
              if(col_obj.name === "gene") col_obj.name = "Pathway Name"
              col_obj.key = column
              col_obj.type = column.split(',')[0]
              // console.log(col_obj)
              new_columns.push(col_obj)
            }
            this.tableDataheader = new_columns
            // console.log(new_rows)
        })
        .catch((error) => {
          console.log(error);
        });
    },

    searchChange() {
      this.loading = true;

      this.loadDir = "";
      this.tableData = [];
      this.loadpage = 1;
      this.getTableData(this.loadpage, "", "");
    },

    //点击单个格子
    heandleclick(row, column) {
      if (column["label"] !== "gene") {
        this.subClu = this.subClucoptions;
        this.isShow = true;
        this.clickGene = row["gene"];
        this.celltype=column["label"]
        this.gloclu = column["type"];
        this.$refs.pathwaydetailPlot.pathwayPlot(row["gene"], column["label"], column["type"], this.tabactiveName);
        toTargetbyid('#detailinfo');
        toTargetbyid('#detailinfo2');
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column }) {
      if (row[column["property"]] === null || column["property"] == 'gene') {
        return {
          background: "white",
        };
      }
      var mycolr = gStyle(parseFloat(row[column["property"]]), 20.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"],
        cursor: mycolr["cursor"],
      };
    },
  },
  components: {
    "v-scpathwaydetail": () => import("./scpathwaydetail.vue"),
    "v-scpathwaydetail2": () => import("./scpathwaydetail.vue"),
  },
};
</script>


<style>
#scDiffExpTable th {
  left: 70px !important;
  height: 140px !important;
}
div#singleCellTitle {
    font-size: 20px;
    font-weight: bold;
    padding-top: 10px;
}
#tab-cluster,
#tab-diff {
  font-size: 18px;
  height: 40px;
  padding: 0px 10px;
  font-weight: bold !important;
}
</style>
