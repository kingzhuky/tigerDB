<template>
  <div id="sigtablepage" class="detail-card">
    <el-card class="infor">
      <el-row>
        <el-col :push="1" :span="22">
          <el-table
            v-loading="loading"
            :data="sigtable"
            max-height="620"
            stripe
            border
            style="width: 100%"
          >
            <!-- <el-table-column property="SignatureID" label="Signature ID" align="center" ></el-table-column> -->
            <el-table-column
              property="SignatureName"
              label="Signature Name"
              align="center"
            ></el-table-column>
            <el-table-column property="PMID" label="PMID" align="center">
              <template slot-scope="scope">
                <a
                  :href="'https://pubmed.ncbi.nlm.nih.gov/' + scope.row.PMID"
                  target="_blank"
                  class="buttonText"
                  >{{ scope.row.PMID }}</a
                >
              </template>
            </el-table-column>
            <el-table-column
              prop="AUC"
              label="AUC"
              align="center"
              sortable
            ></el-table-column>
            <el-table-column label="Detail" align="center" width="120%">
              <template slot-scope="scope">
                <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="showDetail(scope.row.SignatureID)"
                  >Detail</el-button
                >
              </template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </el-card>
    <br />
    <el-card class="infor">
      <v-sigdetail
        ref="immuneSigDetail"
        v-show="isShow"
        :sigID="sigID"
        :sigName="sigName"
      ></v-sigdetail>
    </el-card>
  </div>
</template>

<script>
// import sigtablepage from "./SignatureTable.vue";

//import { hsv2rgb, gStyle } from "../../../static/js/utils.js";
import {
  scrollRow,
  toTarget,
  gStyle,
  move,
  stop,
} from "../../../static/js/utils.js";

export default {
  props: {
    sigID: String,
  },
  data() {
    return {
      sigtable: [],
      // sigID: "SIG1",
      sigName: "T cell-inflamed GEP",
      isShow: true,
      loading: true,
    };
  },
  created() {
    // this.getsigtable();
  },
  mounted() {
    this.getsigtable();
  },
  methods: {
    getsigtable() {
      this.loading = true;
      this.$http
        .get("/tiger/signatureOverview.php", {
          params: {
            table: "siginfo",
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.sigtable = res.data.list;
            this.loading = false;
            this.showDetail(this.sigID);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    showDetail(sigid) {
      // console.log(sigid);
      this.sigID = sigid;
      this.sigName = this.sigtable.find(
        (item) => item.SignatureID === sigid
      ).SignatureName;
      this.$refs.immuneSigDetail.renewDetail(this.sigID);
      setTimeout(() => {
        toTarget(720);
      }, 300);
      // console.log(this.sigID)
    },
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
#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
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

#survivaltable th,
#therapyTable th,
#responseTable th {
  left: 135px !important;
  height: 270px !important;
}

.el-button--primary {
  color: #24b143;
  background-color: #2b5c3a;
  border-color: #2fc45c;
}
</style>
