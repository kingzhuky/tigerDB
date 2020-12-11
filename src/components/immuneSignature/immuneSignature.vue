<template>
  <div>
    <el-card class="box-card-heatmap">
      <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="werTab">
        <el-tab-pane label="Overview" name="diffexp">
          <component :is="sigTabDetail"></component>
        </el-tab-pane>
        <el-tab-pane label="Signature Detail" name="survival">
          <!-- <component :is="survivalVue"></component> -->
        </el-tab-pane>
        <el-tab-pane label="Signature Correlation Matrix" name="signature">
          <!-- <component :is="signatureVue"></component> -->
              <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
      1. Input genes to analyze the immune signature of pan-cancer species.
      <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
      <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
    </el-card>
    <el-card class="anaCard" id="inputCard">
      <el-row>
        <el-col :span="10" :offset="3">
          <span class="label" id="immuinput">Input Gene/Geneset (eg.CD274 OR CD274,CD3D)</span>
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
    <v-immuneSigTable ref="immuSignatureRef" :gene="gene"></v-immuneSigTable>
        </el-tab-pane> 
      </el-tabs>
    </el-card>
  </div>
</template>

<script>
import sigTabDetail from "./SignatureTableDetail";

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

  methods: {
    //搜索
    signatureDiffPlot() {
      this.$refs.immuSignatureRef.getTableData("expresponse", 1);
    },
  },
  components: {
    "v-immuneSigTable": () => import("./immuneSignatureTable.vue"),
  },
};
</script>


<style>
@import "../immuneResponse/style.css";

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
