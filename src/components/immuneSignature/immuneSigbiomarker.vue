<template>
  <div>
    <!-- <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
      1. Input genes to analyze the immune signature of pan-cancer species.
      <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
      <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
    </el-card> -->
    <el-card class="anaCard" id="inputCard">
      <el-row>
        <el-col :span="10" :offset="3">
          <span class="label" id="immuinput"
            >Input Gene/Geneset (eg.CD274 OR CD274,CD3D)</span
          >
        </el-col>
      </el-row>
      <br />
      <el-row>
        <el-col :span="10" :offset="3">
          <el-row>
            <el-input
              v-model="gene"
              @keyup.enter.native="signatureDiffPlot"
              placeholder="Please Input Gene/Geneset (eg.CD274 OR CD274,CD3D)"
            ></el-input>
          </el-row>
        </el-col>

        <el-col :span="6" :offset="1">
          <el-row>
            <el-button
              id="immusignatureplot"
              @click="signatureDiffPlot"
              :disabled="isDisable"
              >Submit</el-button
            >
          </el-row>
        </el-col>
      </el-row>
    </el-card>
    <el-card class="anaCard" id="inputCard" v-show="isShow">
      <el-tabs v-model="tabactiveName" @tab-click="handleClick">
        <el-tab-pane label="AUC Matrix" name="response">
          <v-immuneSigBioRes
            ref="immuSigbioresRef"
            :gene="gene"
          ></v-immuneSigBioRes>
        </el-tab-pane>
        <el-tab-pane label="Survival Matrix" name="survival">
          <v-immuneSigBioSurv
            ref="immuSigbioSurvRef"
            :gene="gene"
          ></v-immuneSigBioSurv>
        </el-tab-pane>
        <el-tab-pane label="Correlation Matrix" name="cormat">
          <v-immuneSigTable
            ref="immuSignatureRef"
            :gene="gene"
          ></v-immuneSigTable>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script>
export default {
  data() {
    return {
      isDisable: false,
      cancer: "",
      loading: false,
      isShow: false,
      loadpage: 1,
      gene: "CD274,CD3D",
      tabactiveName: "response",
    };
  },

  methods: {
    //搜索
    signatureDiffPlot() {
      this.isShow = true;
      this.$refs.immuSignatureRef.getTableData();
      this.$refs.immuSigbioresRef.getTableData();
      this.$refs.immuSigbioSurvRef.getTableData();
    },
  },
  components: {
    "v-immuneSigTable": () => import("./immuneSigCorTable.vue"),
    "v-immuneSigBioRes": () => import("./immuneSigbioresponse.vue"),
    "v-immuneSigBioSurv": () => import("./immuneSigbioSurv.vue"),
  },
};
</script>


<style>
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
#tab-cormat,
#tab-response,
#tab-survival {
  font-size: 20px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}
</style>
