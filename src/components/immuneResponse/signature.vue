<template>
  <div style="margin-bottom: 15px;">
    <!-- <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
      1. Input your intersecting signature. (Using comma to seprate genes. eg. PDCD1, CD274) or select known signature.
      <br />2. Use the average expression of a gene set as a user-defined signature.
      <br />3. View the results of different immunotherapy data through differentially expressed box plots and km survival curves.
      <br />4. 4. Use the AUC table and cox forest chart to find the signature more relevant to the prognosis of immunotherapy.
    </el-card> -->
    <el-card class="anaCard">
      <el-row type="flex" justify="center">
        <el-col :span="10">
          <el-row>
            <el-col>
              <el-row class="sigInput">
                <span class="label">Input Geneset (eg.CD274,CD3D)</span>
              </el-row>
              <el-row>
                <el-input
                  v-loading="inputloading"
                  maxlength="300000"
                  show-word-limit
                  :autosize="{ minRows: 2, maxRows: 4}"
                  type="textarea"
                  v-model="gene"
                  placeholder="CD274,CD3D"
                ></el-input>
              </el-row>
            </el-col>
          </el-row>
          <br />
          <!-- <el-row>
            <el-col :span="8">
              <span id="genesetLabel" class="label">Or Select A GeneSet:</span>
              <br />
              <el-select
                @change="genesetChange"
                v-model="geneset"
                id="genesetSelect"
                placeholder="gene set"
              >
                <el-option v-for="item in genesetOptions" :key="item" :label="item" :value="item"></el-option>
              </el-select>
            </el-col>
            <el-col :span="8">
              <el-button id="resetbt" @click="resetClick">Reset</el-button>
            </el-col>
          </el-row> -->
        </el-col>

        <el-col :span="6" :offset="1">
          <el-row class="sigInput">
            <span class="label">Select A Immunotherapy Response Dataset</span>
          </el-row>

          <el-row>
            <el-select v-model="cancer" placeholder="Cancer" style="width:100%">
              <el-option v-for="item in datasetOptions" :key="item" :label="item" :value="item"></el-option>
            </el-select>
          </el-row>
        </el-col>

        <el-col :span="4" :offset="1">
          <el-row id="submitBt">
            <el-button id="signatureplot" v-on:click="submetBt" :disabled="isDisable">Submit</el-button>
          </el-row>
        </el-col>
      </el-row>
    </el-card>

    <div v-show="allresultshow">
      <div class="anaCard">
        <el-card>
          <el-col :span="7">
            <el-row>
              <el-col :span="12">
                <p class="detail1">Responder Group</p>
                <el-select
                  v-model="responder"
                  multiple
                  placeholder="Choose at least one"
                  style="width:100%"
                >
                  <el-option
                    v-for="item in responseGroupOption"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  ></el-option>
                </el-select>
              </el-col>

              <el-col :span="11" :offset="1">
                <p class="detail1">Non-Responder</p>
                <el-select
                  v-model="noresponder"
                  multiple
                  placeholder="Choose at least one"
                  style="width:100%"
                >
                  <el-option
                    v-for="item in noresponseGroupOption"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  ></el-option>
                </el-select>
              </el-col>
            </el-row>
            <br />
            <el-row class="detail1">Normalized By</el-row>
            <br />
            <el-row class="detail2">
              <el-radio v-model="normalMedDiff" label="None">None</el-radio>
              <el-radio v-model="normalMedDiff" label="gene">Gene</el-radio>
            </el-row>
            <el-row>
              <el-input v-model="normalGeneDiff" v-show='normalMedDiff!="None"' placeholder="Please Input Gene Symbol"></el-input>
            </el-row>
            <br />
            <el-row class="detail1">Log Scale</el-row>
            <br />
            <el-row>
              <el-radio v-model="logScale" label="TRUE">Yes</el-radio>
              <el-radio v-model="logScale" label="FALSE">No</el-radio>
            </el-row>
            <br />
            <el-row class="plot">
              <el-button id="anabt" @click="signatureDiffPlot" style="width:100%">Plot</el-button>
            </el-row>
          </el-col>
          <el-col :span="8" :offset="1" v-show="resultShow">
            <div v-loading="loadingDiff" class="detailimg">
              <p class="imgtitle">Differential Expression between R and NR</p>
              <img id="responseplot" :src="imgUrlBox" />
            </div>
          </el-col>
          <el-col :span="7" :offset="1" v-show="resultShow">
            <div v-loading="loadingDiff" class="detailimg">
              <el-table :cell-style="tableCellStyle" ref="singleTable" border max-height="400" header-row-class-name="tableHead" :data="tableData" @row-click="openDetails" style="100%">
                <el-table-column prop="signature_id" label="ID" width="90%" ></el-table-column>
                <el-table-column prop="Signature_Cite" label="Description" width="170%" ></el-table-column>
                <el-table-column prop="AUC" label="AUC" width="110%" :render-header="renderHeader" sortable> 
                  <template slot-scope="scope">
                    <span class="skucost-pruice">{{scope.row.AUC}}</span>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </el-col>
          <el-col :span="14" v-show="!resultShow" v-loading="loadingDiff">
            <div id="norult">No result</div>
          </el-col>
        </el-card>
      </div>

      <div class="anaCard">
        <el-card>
          <el-col :span="6">
            <el-row class="detail1">Normalized By</el-row>
            <br />
            <el-row class="detail2">
              <el-radio v-model="normalMedSur" label="None">None</el-radio>
              <el-radio v-model="normalMedSur" label="gene">Gene</el-radio>
            </el-row>
            <el-row>
              <el-input v-model="normalGeneSur" v-show='normalMedSur!="None"' placeholder="Please Input Gene Symbol"></el-input>
            </el-row>
            <br />
            <el-row class="detail1">Group Cutoff</el-row>

            <el-row>
              <el-slider v-model="expcutoff" :min="0.10" :max="0.50" :step="0.10"></el-slider>
            </el-row>
            <el-row>
              <el-col :span="12">
                <p>Low Expression</p>
                <el-input v-model="expcutoff" placeholder="0~0.5"></el-input>
              </el-col>
              <el-col :span="11" :offset="1">
                <p>high Expression</p>
                <el-input v-model="expcutoff2" placeholder="0.5~1"></el-input>
              </el-col>
            </el-row>
            <br />

            <el-row class="plot">
              <el-button id="anabt" @click="signatureSurPlot" style="width:100%">Plot</el-button>
            </el-row>
            <br />
          </el-col>
          <el-col :span="8" :offset="1" v-show="surresultShow">
            <div v-loading="loadingSur" class="detailimg">
              <p class="imgtitle">Survival Analysis</p>
              <img width="450px" :src="imgUrlSign" />
            </div>
          </el-col>
          <el-col :span="8" :offset="1" v-show="surresultShow">
            <div class="detailimg">
              <el-table
                ref="singleTable"
                border
                max-height="500"
                :data="tableDataSur"
                v-loading="loadingSur"
                :row-style="tableCellStyleSur"
                header-row-class-name="tableHead"
                @row-click="openDetails"
                style="100%"
              >
                <el-table-column prop="signature_id" label="ID" width="90%" ></el-table-column>
                <el-table-column prop="Signature_Cite" label="Description" width="130%" ></el-table-column>
                <el-table-column prop="HR" label="HR" width="80%" sortable></el-table-column>
                <el-table-column prop="CI95" label="95% CI" width="100%" sortable></el-table-column>
                <el-table-column prop="PValue" label="P Value" width="100%" sortable></el-table-column>
              </el-table>
            </div>
          </el-col>
          <el-col :span="18" v-show="!surresultShow" v-loading="loadingSur">
            <div id="norult">No result</div>
          </el-col>
        </el-card>
      </div>
    </div>
    <v-goTop></v-goTop>
  </div>
</template>


<script>
import goTop from "../public/goTop";
import qs from "qs";
import {
  gStyle
} from "../../../static/js/utils.js";

export default {
  data() {
    return {
      resultShow: true,
      surresultShow: true,
      expcutoff: 0.50,
      expcutoff2: 0.50,
      inputloading: false,
      logScale: "FALSE",
      responder: ["CR", "PR"],
      noresponder: ["PD", "SD"],
      tableData: [],
      wercordataset: "",
      wercorgene_data: [
        { value: "HNRNPA2B1" },
        { value: "HNRNPC" },
        { value: "VIRMA" },
        { value: "METTL3" },
        { value: "METTL14" },
        { value: "WTAP" },
        { value: "YTHDF1" },
        { value: "YTHDF2" },
        { value: "YTHDF3" },
        { value: "YTHDC1" },
        { value: "YTHDC2" },
        { value: "IGF2BP1" },
        { value: "IGF2BP2" },
        { value: "IGF2BP3" },
        { value: "FTO" },
        { value: "RBM15" },
        { value: "RBM15B" },
        { value: "METTL16" },
        { value: "ALKBH5" }
      ],
      geneset: "",
      genesetOptions: [],
      datasetOptions: [],

      loadingDiff: true,
      loadingSur: true,
      loadpage: 1,
      genelastclick: "",
      isDisable: false,
      cancer: "Melanoma-PRJEB23709_ALL",
      gene: "CD274,CD3D",
      normalMedDiff: "None",
      normalGeneDiff: "",
      normalMedSur: "None",
      normalGeneSur: "",
      responseGroupOption: [
        {
          value: "CR",
          label: "CR"
        },
        {
          value: "PR",
          label: "PR"
        }
      ],
      noresponseGroupOption: [
        {
          value: "PD",
          label: "PD"
        },
        {
          value: "SD",
          label: "SD"
        }
      ],
      imgpath: "",
      imgpathSur: "",
      imgpathBox: "",
      imgpathBar: "",
      allresultshow: false,
      tableDataSur: [],
    };
  },

  computed: {
    imgUrlBox: function() {
      return "tiger/img/" + this.imgpathBox + ".png";
    },
    imgUrlBar: function() {
      return "tiger/img/" + this.imgpathBar + ".png";
    },
    imgUrlSign: function() {
      return "tiger/img/" + this.imgpath + ".png";
    },
    imgUrlSignSur: function() {
      return "tiger/img/" + this.imgpathSur + ".png";
    }
  },

  mounted: function() {
    this.getColumn("tablecolumn", "immuneresponseunion");
    this.getgeneset("siginfo", "SignatureName");
  },

  watch: {
    expcutoff() {
      this.expcutoff2 = (1 - this.expcutoff).toFixed(2);
    },
    expcutoff2() {
      this.expcutoff = (1 - this.expcutoff2).toFixed(2);
    }
  },

  methods: {
    renderHeader(h){
       return h('span', {}, [
        h('span', {}, 'AUC'),
        h('el-popover', { props: { placement: 'top-start', width: '200', trigger: 'hover', content: 'AUC means the immune signature is more related to immunotherapy response' }}, [
           h('i', { slot: 'reference', class:'el-icon-question'}, '')
          ])
       ])
    },
    gettableDataSur(jsonUrl) {
      var that = this;
      this.$http
        .get("/tiger/img/" + jsonUrl + ".json")
        .then(function(res) {
          that.tableDataSur = res.data;
        })
        .catch(function(res) {
          // console.log(res);
        });
    },
    tableCellStyleSur({row}) {
      // console.log(row["PValue"])
      var mycolr = ""
      if(parseFloat(row["PValue"]) < 0.1){
        mycolr = "#f0b6b6"
      }else{
        mycolr = "rgb(255,255,255)"
      }
      return {
        background: mycolr
      };
    },
    openDetails(row){
      // console.log(row.signature_id);
      this.$router.push({
        name: "immuneSignature",
        params: {
          sigid: row.signature_id,
        },
      });
    },
    getgeneset(tabl, mycolumn) {
      this.$http
        .get("/tiger/tablecolumn.php", {
          params: {
            tabl: tabl,
            mycolumn: mycolumn
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            //console.log(res.data.list);
            this.genesetOptions = res.data.list;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    getColumn(tabl, mycolumn) {
      this.$http
        .get("/tiger/tablecolumn.php", {
          params: {
            tabl: tabl,
            mycolumn: mycolumn
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            //console.log(res.data.list);
            this.datasetOptions = res.data.list;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    resetClick() {
      this.gene = "";
    },
    genesetChange() {
      this.inputloading = true;
      var that = this;

      var params = qs.stringify({ gene: this.geneset, type: "siginfo" });
      this.$http
        .post("/tiger/signature2geneset.php", params, { emulateJSON: true })
        .then(function(res) {
          that.gene = res.data.list[0].GeneSymbol;
          that.inputloading = false;
        })
        .catch(function(res) {
          console.log(res);
        });
    },

    checkInput() {
      if (this.normalMedDiff !== "None" && this.normalGeneDiff.length == 0) {
        alert("please input Normalized gene or Cell fration");
        return false;
      }
      return true;
    },

    submetBt() {
      if (this.gene !== "" && this.caner !== "") {
        this.allresultshow = true;
        this.normalMedDiff = "None";
        this.normalGeneDiff = "";
        this.normalMedSur = "None";
        this.normalGeneSur = "";
        this.expcutoff = 0.50;
        this.expcutoff2 = 0.50;
        this.logScale = "FALSE";
        this.responder = ["CR", "PR"];
        this.noresponder = ["PD", "SD"];
        this.signatureDiffPlot();
        this.signatureSurPlot();
      } else {
        alert("please input Geneset and Select a signature type");
      }
    },

    gettableData(jsonUrl) {
      var that = this;
      this.$http
        .get("/tiger/img/" + jsonUrl + ".json")
        .then(function(res) {
          that.tableData = res.data;
        })
        .catch(function(res) {
          console.log(res);
        });
    },

    signatureDiffPlot() {
      if (this.checkInput()) {
        this.resultShow = true;

        var that = this;
        that.loadingDiff = true;
        this.$http
          .get("/tiger/responseSigDif.php", {
            params: {
              gene: this.gene.trim(),
              mergedatasets: this.cancer,
              responder: this.responder.join(","),
              noresponder: this.noresponder.join(","),
              normalMed: this.normalMedDiff,
              normalGene:
                this.normalMedDiff === "None" ? "None" : this.normalGeneDiff,
              logScale: this.logScale,
              datatype: "png"
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              that.resultShow = true;
              let imgpath = res.data.output[0].split(",");

              setTimeout((that.imgpathBox = imgpath[0]), 1000);
              that.gettableData(imgpath[1]);
              that.loadingDiff = false;
              //console.log(that.imgpath);
            } else {
              that.resultShow = false;
            }
          })
          .catch(function(res) {
            console.log(res);
          });
      }
    },

        tableCellStyle({ row, column}) {
      var mycolr = gStyle(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"]
      };
    },

    signatureSurPlot() {
      if (this.checkInput()) {
        var that = this;
        that.loadingSur = true;
        that.surresultShow = true;
        this.$http
          .get("/tiger/responseSigSur.php", {
            params: {
              gene: this.gene.trim(),
              mergedatasets: this.cancer,
              expcutoff: this.expcutoff,
              normalMed: this.normalMedSur,
              normalGene:
                this.normalMedSur === "None" ? "None" : this.normalGeneSur,
              datatype: "png"
            }
          })
          .then(function(res) {
            if (res.data.status == 0) {
              let imgpath2 = res.data.output[2].split(",");
              setTimeout((that.imgpath = imgpath2[0]), 1000);
              that.gettableDataSur(imgpath2[1]);
              // that.imgpath = imgpath2[0];
              // that.imgpathSur = imgpath2[1];
              that.loadingSur = false;
            } else {
              that.surresultShow = false;
            }
          })
          .catch(function(res) {
            console.log(res);
          });
      }
    }
  },

  components: {
    "v-goTop": goTop
  }
};
</script>

<style>
.anaCard {
  padding-top: 20px;
}

.sigInput {
  padding-bottom: 10px;
}
/* div#signatSele {
  padding-top: 10px;
} */
.label {
  font-size: 16px;
}

div#submitBt {
  padding-top: 13px;
}

#signatureplot {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}

#readme {
  color: rgb(20, 146, 140);
  font-weight: bold;
  font-size: 20px;
  padding-bottom: 10px;
}
#signatSele > .el-select {
  padding-top: 10px;
}
div#readmeCard {
  font-size: 16px;
  line-height: 22px;
  border-color: rgb(20, 146, 140);
  margin-bottom: 20px;
}

#signatureplot {
  margin-top: 14px;
}

button#resetbt {
  margin-top: 18px;
}

#responseplot {
  width: 480px;
}
.tableHead{
  font-size: 18px;
  color: #000000;
  font-weight:bold;
}
.el-table--enable-row-hover .el-table__body tr:hover{
  cursor: pointer;
}
</style>
