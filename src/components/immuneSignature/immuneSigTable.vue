<template>
  <div id='sigtablepage'>
    <el-row>
        <el-col :push="1" :span="22">
        <el-table :data="sigtable" max-height="620" stripe border style="width: 100%">
            <el-table-column property="Signature_ID" label="Signature ID" align="center" ></el-table-column>
            <el-table-column property="Signature_Name" label="Signature Name" align="center" ></el-table-column>
            <el-table-column property="PMID" label="PMID" align="center">
                <template slot-scope="scope">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                    target="_blank"
                    class="buttonText">{{scope.row.PMID}}</a>
                </template>
              </el-table-column>
            <el-table-column prop="Immune_Response_Correlation" label="AUC" align="center"></el-table-column>
              <el-table-column label="Detail" align="center">
                <template slot-scope="scope">
                    <el-button
                    type="success"
                    plain
                    icon="el-icon-s-marketing"
                    @click="showDetail(scope.row.Signature_ID)"
                    >Detail</el-button>
                </template>
            </el-table-column>
        </el-table>
        </el-col>
    </el-row>
    <el-row>
      <v-sigdetail
        ref="immuneSigDetail"
        v-show="isShow"
        :sigID="sigID"
      ></v-sigdetail>
    </el-row>
  </div>
</template>

<script>
// import sigtablepage from "./SignatureTable.vue";

//import { hsv2rgb, gStyle } from "../../../static/js/utils.js";

export default {
  data() {
    return {
      sigtable:[],
      sigID:"SIG1",
      isShow: true,
    };
  },
  created() {
    this.getsigtable();
  },
  mounted() {
    this.getsigtable();
  },
  methods: {
    getsigtable() {
      this.$http.get("/tiger/immuneSigView.json").then((res) => {
        this.sigtable = res.data;
        // console.log(this.sigtable)
      });
      // console.log(this.sigtable)
    },
    showDetail(sigID){
      // console.log(sigID)
      this.sigID = sigID
      this.$refs.immuneSigDetail.articleDetail(this.sigID)
      // console.log(this.sigID)
    }
  },
  components: {
    "v-sigdetail": () => import("./immuneSigTableDetail.vue"),
  },
};
</script>

<style>
/* div#sigtablepage {
  margin-bottom: 20px;
} */

#tab-diffexp,
#tab-survival,
#tab-signature {
  font-size: 20px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}

.box-card-heatmap {
  width: 1380px;
  margin: 0 auto;
}
.info {
  width: 1350px;
}

#survivaltable th,#therapyTable th, #responseTable th {
  left: 135px !important;
  height: 270px !important;
}

@import "../immuneResponse/style.css";
.el-button--primary {
  color: #24b143;
  background-color: #2fc45c;
  border-color: #2fc45c;
}
</style>
