<template>
  <div>
    <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
      1. Input genes to analyze the immune signature of pan-cancer species.
      <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
      <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
    </el-card>
    <el-card class="anaCard" id="inputCard">
      <el-row>
        <el-col :span="10" :offset="3">
          <span class="label" id="immuinput">Input Gene/Geneset (eg. CD274 OR CD274,CD3D)</span>
        </el-col>
      </el-row>
      <br />
      <el-row>
        <el-col :span="10" :offset="3">
          <el-row>
            <el-input v-model="gene" @keyup.enter.native="signatureDiffPlot" placeholder="SEMA3F"></el-input>
          </el-row>
        </el-col>

        <el-col :span="6" :offset="1">
          <el-row>
            <el-button
              id="immusignatureplot"
              v-on:click="signatureDiffPlot"
              :disabled="isDisable"
              
            >Submit</el-button>
          </el-row>
        </el-col>
      </el-row>
    </el-card>

    <v-immuneSigTable ref="immuSignatureRef" :gene="gene" ></v-immuneSigTable>
  </div>
</template>

<script>
import {
  scrollRow,
  scrollCol,
  getTableData,
  toTarget,
  gStyle,
  move,
  stop,
} from "../../static/js/utils.js";

export default {
  data() {
    return {
      isDisable: false,
      cancer: "",
      tableDataheader: [],
      datatype: "",
      signature: "",
      m6aMsg: "",
      cancerMsg: "",
      loading: false,
      isShow: false,
      loadpage: 1,
      tableData: [],
      search: "",
      loadDir: "",
      gene: "CD274,CD3D",
      path: "",
    };
  },

 

  // mounted() {
  //   this.getColumn("tablecolumn", "tcga");
  // },

  methods: {
        //搜索
    signatureDiffPlot() {
      this.$refs.immuSignatureRef.getTableData("expresponse",1);
    },

   
  },
  components: {
    "v-immuneSigTable": () => import("./immuneSignatureTable.vue"),
  },
};
</script>


<style>
@import "./immuneResponse/style.css";

#immuneSigTable th {
  left: 35px !important;
  height: 70px !important;
}

#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>
