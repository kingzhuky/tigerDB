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
            <el-table-column
              property="DatasetID"
              label="Dataset ID"
              align="center"
            ></el-table-column>
            <el-table-column
              property="Dataset"
              label="Dataset"
              align="center"
            ></el-table-column>
            <el-table-column
              property="CancerType"
              label="Cancer Type"
              align="center"
            ></el-table-column>
            <el-table-column
              property="Therapy"
              label="Therapy"
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
              property="SampleSize"
              label="Sample Size"
              align="center"
            ></el-table-column>
            <el-table-column
              property="RNR"
              label="Response : Non-Response"
              align="center"
            >
              <template slot-scope="scope">
                {{ scope.row.ResponseSampleCount }} :
                {{ scope.row.NonresponseSampleCount }}
              </template>
            </el-table-column>
            <el-table-column
              property="RNR"
              label="Pre-therapy : Post-therapy"
              align="center"
            >
              <template slot-scope="scope">
                {{ scope.row.PretherapySampleCount }} :
                {{ scope.row.PosttherapySampleCount }}
              </template>
            </el-table-column>
            <el-table-column label="Detail" align="center" width="120%">
              <template slot-scope="scope">
                <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="showDetail(scope.row.DatasetID)"
                  >Detail</el-button
                >
              </template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </el-card>
    <el-card
      id="detailinfo"
      class="infor"
      v-loading="artloading"
      v-show="isShow"
    >
      <p class="card-title">{{ datasetid }} Details</p>
      <el-row class="detailimg">
        <v-resultcard
          :conditi="'Responder'"
          :datasetid="datasetid"
          :title="'Differential expression between responder and non-responder'"
          ref="immuResponseVueRefResponder"
        ></v-resultcard>
        <v-resultcard
          :conditi="'Therapy'"
          :datasetid="datasetid"
          :title="'Differential expression between pre-therapy and post-therapy'"
          ref="immuResponseVueRefTherapy"
        ></v-resultcard>
        <v-resultcard
          :conditi="'Survival'"
          :datasetid="datasetid"
          :title="'Survival analysis'"
          ref="immuResponseVueRefSurvival"
        ></v-resultcard>
      </el-row>
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
  data() {
    return {
      sigtable: [],
      datasetid: "GBM-PRJNA482620_anti-PD-1",
      isShow: false,
      loading: true,
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
      this.$http.get("/tiger/datesetinfo.json").then((res) => {
        this.sigtable = res.data;
        this.loading = false;
        // console.log(this.sigtable)
      });
      // console.log(this.sigtable)
    },
    showDetail(datasetid) {
      // console.log(datasetid)
      this.isShow = true;
      this.datasetid = datasetid;
      setTimeout(() => {
        toTarget(500);
      }, 300);
      // this.$refs.immuneSigDetail.renewDetail(this.datasetid)

      // console.log(this.datasetid)
    },
    plot() {
      if ((this.olddatasetid !== this.datasetid) | (this.olddatasetid === "")) {
        this.olddatasetid = this.datasetid;
        this.$refs.immuResponseVueRefResponder.getTableData(
          this.datasetid,
          "Responder"
        );
        this.$refs.immuResponseVueRefTherapy.getTableData(
          this.datasetid,
          "Therapy"
        );
        this.$refs.immuResponseVueRefSurvival.getTableData(
          this.datasetid,
          "Survival"
        );
      }
    },
  },

  components: {
    "v-resultcard": () => import("./datasetoverviewDetail.vue"),
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
