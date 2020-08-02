<template>
  <div>
    <el-row id="coExpInput">
      <br />
      <br />
      <el-col :span="8" :offset="6">
        <el-autocomplete
        v-model="searchinput"
        placeholder="Please Input Gene Symbol"
        :fetch-suggestions="querySearchAsyncA"
      ></el-autocomplete>
      </el-col>
      <el-col :span="4">
        <el-button id="homebt" @click="searchClick" icon="el-icon-search"></el-button>
      </el-col>
    </el-row>
    <br />
    <br />
    <el-col :span="4" :offset="20">
      <el-autocomplete
        v-model="search"
        placeholder="Please Input Gene Symbol"
        :fetch-suggestions="querySearchAsync"
      ></el-autocomplete>
    </el-col>
    <div v-show="tableShow" v-loading="loading">
      <el-table
        class="wertable"
        id="scCoExpTable"
        ref="singleTable"
        border
        max-height="800"
        :data="tableData.filter(data => !search || data.gene.toLowerCase().includes(search.toLowerCase()))"
        @cell-click="heandleclick"
        style="100%"
      >
        <el-table-column
          v-for="(item,index) in tableDataheader"
          :key="index"
          :property="item"
          :label="item"
          sortable
          align="center"
          width="80"
        ></el-table-column>
        <el-table-column property=" " label=" " align="center" width="120"></el-table-column>
      </el-table>
    </div>

    <!-- 详细页显示与否 -->
    <v-coexpdetail
      ref="detailPlot"
      v-show="isShow"
      :gloclu="gloclu"
      :gene="searchinput"
      :cancer="cancer"
    ></v-coexpdetail>
  </div>
</template>

<script>
import {
  scrollRow,
  scrollCol,
  toTarget,
  gStyle,
  move,
  stop,
} from "../../../static/js/utils.js";

export default {
  props: {
    cancer: String,
    gloclu: String,
  },
  data() {
    return {
      tableShow: false,
      cancer: "",
      searchinput: "CXCL13",
      wercorcancer_data: [
        {
          value: "ACC",
          label: "ACC",
        },
        {
          value: "BLCA",
          label: "BLCA",
        },
        {
          value: "BRCA",
          label: "BRCA",
        },
        {
          value: "CESC",
          label: "CESC",
        },
        {
          value: "CHOL",
          label: "CHOL",
        },
        {
          value: "COAD",
          label: "COAD",
        },
        {
          value: "DLBC",
          label: "DLBC",
        },
        {
          value: "ESCA",
          label: "ESCA",
        },
        {
          value: "GBM",
          label: "GBM",
        },
        {
          value: "HNSC",
          label: "HNSC",
        },
        {
          value: "KICH",
          label: "KICH",
        },
        {
          value: "KIRC",
          label: "KIRC",
        },
        {
          value: "KIRP",
          label: "KIRP",
        },
        {
          value: "LIHC",
          label: "LIHC",
        },
        {
          value: "LAML",
          label: "LAML",
        },
        {
          value: "LGG",
          label: "LGG",
        },
        {
          value: "LUAD",
          label: "LUAD",
        },
        {
          value: "LUSC",
          label: "LUSC",
        },
        {
          value: "MESO",
          label: "MESO",
        },
        {
          value: "OV",
          label: "OV",
        },
        {
          value: "PAAD",
          label: "PAAD",
        },
        {
          value: "PCPG",
          label: "PCPG",
        },
        {
          value: "READ",
          label: "READ",
        },
        {
          value: "SKCM",
          label: "SKCM",
        },
        {
          value: "SARC",
          label: "SARC",
        },
        {
          value: "STAD",
          label: "STAD",
        },
        {
          value: "TGCT",
          label: "TGCT",
        },
        {
          value: "THCA",
          label: "THCA",
        },
        {
          value: "THYM",
          label: "THYM",
        },
        {
          value: "UCEC",
          label: "UCEC",
        },
        {
          value: "UCS",
          label: "UCS",
        },
      ],
      search: "",
      datatype: {
        type: String,
      },
      m6aMsg: {
        type: String,
      },
      cancerMsg: {
        type: String,
      },
      loading: false,
      isShow: false,
      loadpage: 1,
      tableData: [],
      loadDir: "",
      tableDataheader: [],
      oldcancer: "",
      oldgloclu: "",
    };
  },

  mounted: function () {
    this.oldcancer = this.cancer;
    this.oldgloclu = this.gloclu;
    this.getTableData();
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
  },

  methods: {
    querySearchAsync(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.search,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },
    querySearchAsyncA(queryString, cb) {
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
    plot() {
      if (
        (this.oldcancer !== this.cancer) |
        (this.oldcancer === "") |
        (this.oldgloclu !== this.gloclu) |
        (this.oldgloclu === "")
      ) {
        this.oldcancer = this.cancer;
        this.oldgloclu = this.gloclu;
        this.getTableData(1, "", "");
      }
    },
    searchClick() {
      this.getTableData();
    },
    getTableData2(file) {
      this.tableData = [];
      this.$http
        .get("/tiger/img/" + file + ".json")
        .then((res) => {
          this.loading = false;
          this.tableDataheader = Object.keys(res.data[0]);
          this.tableData = res.data;
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getTableData() {
      this.tableShow = true;
      this.loading = true;
      this.$http
        .get("/tiger/scimmucoexp.php", {
          params: {
            cancer: this.cancer,
            gloclu: this.gloclu,
            gene: this.searchinput.trim(),
          },
        })
        .then((res) => {
          if (res.data.status === 0) {
            this.getTableData2(res.data.output[0]);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    //点击单个格子
    heandleclick(row, column) {
      this.datatype = "expression";
      if (column["label"] !== "gene") {
        this.isShow = true;
        this.$refs.detailPlot.Plot(row["gene"], column["label"]);
        //this.$refs.detailPlot.tableDetail("expression", 1, "");
        toTarget(820);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column }) {
      var mycolr = gStyle(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"],
      };
    },
  },
  components: {
    "v-coexpdetail": () => import("./coExpdetail.vue"),
  },
};
</script>


<style>
.el-table__fixed {
  cursor: not-allowed;
}

#coExpInput .el-autocomplete {
    width: 100%;
}

#scCoExpTable th {
  left: 70px !important;
  height: 140px !important;
}
</style>
