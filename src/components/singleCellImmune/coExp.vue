<template>
  <div>
    <el-row class="selectrow">
      <br />
      <el-col :span="6" :offset="2">
        <span class="demonstration">Global Cluster:</span>
        <el-select v-model="GlobalCluster" @change="GlobalClusterChange">
          <el-option
            v-for="item in gloCluoptions"
            :key="item.GlobalCluster"
            :label="item.GlobalCluster"
            :value="item.GlobalCluster"
          ></el-option>
        </el-select>
      </el-col>
      <el-col :span="6">
        <span class="demonstration">Cell Type:</span>
        <el-select v-model="CellType" v-loading="CellTypeLoading" @change="subClusterChange">
          <el-option
            v-for="item in CellTypeCluoptions"
            :key="item.CellType"
            :label="item.CellType"
            :value="item.CellType"
          ></el-option>
        </el-select>
      </el-col>
      <el-col :span="6">
        <span class="demonstration">Gene:</span>
        <el-autocomplete
          v-model="searchinput"
          placeholder="Please Input Gene Symbol"
          :fetch-suggestions="querySearchAsyncA"
          @keyup.enter.native="searchTable"
        ></el-autocomplete>
      </el-col>
      <el-col :span="4">
        <el-button @click="searchTable">Search</el-button>
      </el-col>
    </el-row>
    <br />
    <br />
    <v-singleCellImmunityCorTable
      v-show="singleCellImmunityCorTableShow"
      ref="coExpRef"
      :seargene="searchinput"
      :CancerType="CancerType"
      :GlobalCluster="GlobalCluster"
      :CellType="CellType"
    ></v-singleCellImmunityCorTable>
  </div>
</template>

<script>
export default {
  props: {
    CancerType: String,
    gloCluoptions: Array,
  },
  data() {
    return {
      singleCellImmunityCorTableShow: false,
      tableShow: false,
      searchinput: "CXCL13",
      oldcancer: "",
      CellType: "",
      GlobalCluster: this.gloCluoptions[0].GlobalCluster,
    };
  },

  mounted: function () {
    this.$nextTick(() => {
      this.oldcancer = this.CancerType;
      this.getgloClu();
      this.getCellType();
    });
  },

  methods: {
    searchTable() {
      this.singleCellImmunityCorTableShow = true;
      this.$refs.coExpRef.getDiagramData(
        this.searchinput,
        "singleCellCorTumor",
        this.CancerType,
        this.GlobalCluster,
        this.CellType,
        1,
        20
      );
    },
    cancerSelectChange() {
      this.getgloClu();
    },

    CancerTypeSelectChange() {
      this.GlobalCluster = this.gloCluoptions[0].GlobalCluster;
      this.getCellType();
    },
    GlobalClusterChange() {
      this.getCellType();
    },
    getCellType() {
      this.CellTypeLoading = true;
      this.$http
        .get("/tiger/scCelltype.php", {
          params: {
            CancerType: this.CancerType,
            GlobalCluster: this.GlobalCluster,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.CellTypeLoading = false;
            this.CellTypeCluoptions = res.data.list;
            this.CellType = res.data.list[0].CellType;
          }
        });
    },
    getgloClu() {
      this.$http
        .get("/tiger/scglocluster.php", {
          params: {
            cancer: this.CancerType,
            type: "homescinfo",
          },
        })
        .then((res) => {
          this.gloCluoptions = res.data.list;
          this.gloClu = res.data.list[0].glo;
        });
    },
    querySearchAsync(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.search,
            species: "Human",
          }
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
        (this.oldcancer !== this.CancerType) |
        (this.oldcancer === "") |
        (this.oldgloclu !== this.gloclu) |
        (this.oldgloclu === "")
      ) {
        this.oldcancer = this.CancerType;
        this.oldgloclu = this.gloclu;
      }
    },
  },

  components: {
    "v-singleCellImmunityCorTable": () =>
      import("../search/singleCellImmunityCorTable.vue"),
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
