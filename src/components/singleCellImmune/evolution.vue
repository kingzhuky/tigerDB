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
    <v-celltypedetail 
       ref="detailPlot"
      v-show="isShow"
      :gene="searchinput"
      :cancer="cancer"
      :tabname="'evolution'"></v-celltypedetail>
   
  </div>
</template>

<script>

export default {
  props: {
    cancer: String,
    gloclu: String,
  },
  data() {
    return {
      tableShow: false,
      searchinput: "CXCL13",
      isShow:false
    };
  },

  methods: {
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
    searchClick() {
      this.isShow=true
      this.$refs.detailPlot.evoluPlot(this.searchinput);
    
    },
   
  },
  components: {
    "v-celltypedetail": () => import("./celltypedetail.vue"),
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
