<template>
  <div>
    <el-card class="anaCard" id="inputCard">
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
import immuneSigTable from "../immuneSignature/immuneSigCorTable.vue";
import immuneSigBioRes from "../immuneSignature/immuneSigbioresponse.vue";
import immuneSigBioSurv from "../immuneSignature/immuneSigbioSurv.vue";

export default {
  props: {
    gene: { type: String },
  },
  data() {
    return {
      oldgene: "",
      tabactiveName: "response",
    };
  },

  methods: {
    //搜索
    plot() {
      if ((this.oldgene !== this.gene) | (this.oldgene === "")) {
        this.oldgene = this.gene;
        this.signatureDiffPlot();
      }
    },
    signatureDiffPlot() {
      this.$refs.immuSignatureRef.getTableData();
      this.$refs.immuSigbioresRef.getTableData();
      this.$refs.immuSigbioSurvRef.getTableData();
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.signatureDiffPlot();
    });
  },
  created() {
    this.$nextTick(() => {
      this.signatureDiffPlot();
    });
  },
  components: {
    "v-immuneSigTable": immuneSigTable,
    "v-immuneSigBioRes": immuneSigBioRes,
    "v-immuneSigBioSurv": immuneSigBioSurv,
  },
};
</script>


<style>
#immuneSigTable th {
  left: 35px !important;
  height: 80px !important;
}
#survivaltable th {
  left: 135px !important;
  height: 250px !important;
}
#tab-cormat,
#tab-response,
#tab-survival {
  font-size: 18px;
  height: 40px;
  padding: 0px 10px;
  font-weight: bold !important;
}
</style>
