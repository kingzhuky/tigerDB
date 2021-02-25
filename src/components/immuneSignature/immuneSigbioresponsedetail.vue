<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor">
        <el-card class="box-card-return">
          <div class="text item">
            <h1 style="font-weight: bold;font-size:25px;text-align:center">{{ sign }} -- {{dataset}}</h1>
          </div>
        </el-card>
      </div>
      <div class="infor">
        <el-card>
          <p class="card-title">Correlation between Custom Signature and Immunetherapy Response</p>
          <el-row v-loading="loading" class="detailimg">
            <el-col span="8" push="2" v-show="aucshow">
              <el-table 
                :cell-style="tableCellStyle"
                ref="singleTable" 
                border 
                max-height="400" 
                header-row-class-name="tableHead" 
                :data="tableData" 
                @row-click="openDetails" 
                style="100%"
              >
                <el-table-column prop="signature_id" label="ID" width="90%" ></el-table-column>
                <el-table-column prop="Signature_Cite" label="Description" width="170%" ></el-table-column>
                <el-table-column prop="AUC" label="AUC" width="110%" :render-header="renderHeader" sortable> 
                  <template slot-scope="scope">
                    <span class="skucost-pruice">{{scope.row.AUC}}</span>
                  </template>
                </el-table-column>
              </el-table>
            </el-col>
            <el-col span="8" push="2" v-show="survshow">
              <div class="wergeneinfo">
                <div class="detailimg">
                  <el-table
                    ref="singleTable"
                    border
                    max-height="500"
                    :data="tableDataSur"
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
              </div>
            </el-col>
          </el-row>
          <!-- <p class="card-title">Signature Informations</p>
          <el-table :data="articleData" style="width: 100%" v-loading="artloading">
            <el-table-column prop="title" label width="180"></el-table-column>
            <el-table-column prop="value" label></el-table-column>
          </el-table> -->
        </el-card>
      </div>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";

export default {
  props: {
    datatype: {
      type: String,
    },
    sign: {
      type: String,
    },
    path: {
      type: String,
    },
    dataset:{

    }
  },

  data() {
    return {
      articleData: [],
      tableLoading: "",
      normalMed: "None",
      normalGene: "",
      imgpath: "",
      loading: true,
      corMed: "pearson",
      signature: "",
      resultShow: true,
      artloading: false,
      tableData: [],
      tableDataSur: [],
      survshow: true,
      aucshow: true,
    };
  },

  methods: {
    checkInput() {
      if (this.normalMed !== "None" && this.normalGene.length == 0) {
        alert("please input Normalized gene or Cell fration");
        return false;
      }
      return true;
    },
    // articleDetail(sample) {
    //   var that = this;
    //   that.artloading = true;
    //   this.$http
    //     .get("/tiger/immunescreendetail2.php", {
    //       params: {
    //         tabl: "siginfo",
    //         colu: "SignatureID",
    //         coluvalue: sample,
    //       },
    //     })
    //     .then(function (res) {
    //       that.articleData = res.data.list;
    //       that.artloading = false;
    //     })
    //     .catch(function (res) {
    //       console.log(res);
    //     });
    // },
    gettable(genestr,datasetid) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/2.5.1-generate_sigtable.php", {
          params: {
            gene: genestr.trim().replace(" ",""),
            dataset: datasetid
          },
        })
        .then(function (res) {
          console.log(res.data.output[0].split(","))
          if(res.data.output[0].split(",")[0] != "0"){
            that.gettableData(res.data.output[0].split(",")[0])
          }else{
            that.aucshow = false
          }
          
          if(res.data.output[0].split(",")[1] != "0"){
            that.gettableDataSur(res.data.output[0].split(",")[1])
          }else{
            that.survshow = false
          }
          
          that.loading = false;
        })
        .catch(function (res) {
          console.log(res);
        });
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
    gettableDataSur(jsonUrl) {
      var that = this;
      this.$http
        .get("/tiger/img/" + jsonUrl + ".json")
        .then(function(res) {
          that.tableDataSur = res.data;
        })
        .catch(function(res) {
          console.log(res);
        });
    },
    tableCellStyle({ row, column}) {
      var mycolr = gStyle(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"]
      };
    },
  },
  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
</style>


