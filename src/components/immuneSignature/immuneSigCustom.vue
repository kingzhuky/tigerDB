<template>
    <div>
    <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
    1. Input genes to analyze the immune signature of pan-cancer species.
    <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
    <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
    </el-card>
    <el-row>
        <el-col push="2" span="10" align="center">
            <el-upload
            class="upload-demo"
            action="/tiger/upload/"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :before-remove="beforeRemove"
            multiple
            :limit="1"
            :on-exceed="handleExceed"
            :file-list="expDataFile">
            <el-button id="immusignatureplot">Upload Expression Matrix</el-button>
            </el-upload>
        </el-col>
        <el-col push="8" span="2">
            <el-button id="immusignatureplot" @click="handleEdit">Example</el-button>
        </el-col>
        
    </el-row>
    <br />
    <el-row>
      <el-col push="2" span="10" align="center">
            <el-upload
            class="upload-demo"
            action="/tiger/upload/"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :before-remove="beforeRemove"
            multiple
            :limit="1"
            :on-exceed="handleExceed"
            :file-list="annoDataFile">
            <el-button id="immusignatureplot">Upload Group Anno File</el-button>
            </el-upload>
        </el-col>
      <el-col push="8" span="2">
        <el-button id="immusignatureplot" @click="analysisData">Submit</el-button>
      </el-col>
    </el-row>
    <el-row>
      <p class="card-title">Signature Score Table</p>
        <div class="detailimg">
          <el-table
            id="immuneSigTable"
            border
            max-height="800"
            v-loading="loading"
            :data="sigsampletable"
            @cell-click="heandleclick"
            :cell-style="tableCellStyle"
            style="100%"
          >
            <el-table-column
              v-for="(item,index) in sigsampletableheader"
              :key="index"
              :property="item"
              :label="item"
              sortable
              align="center"
              width="80"
            >
            </el-table-column>
          </el-table>
        </div>
      <p class="card-title">Signature Score Table</p>
        <div class="detailimg">
          <el-table
            id="immuneSigGroupTable"
            border
            max-height="800"
            v-loading="grouploading"
            :data="siggrouptable"
            @cell-click="heandleclick"
            :cell-style="tableCellStyle"
            style="100%"
          >
            <el-table-column
              v-for="(item,index) in siggrouptableheader"
              :key="index"
              :property="item"
              :label="item"
              sortable
              align="center"
              width="80"
            >
            </el-table-column>
          </el-table>
        </div>
    </el-row>

    </div>
</template>


<script>
  import {
    scrollCol,
    toTarget,
    gStyle,
    move,
    stop,
  } from "../../../static/js/utils.js";
  export default {
    data() {
      return {
        fileList: [],
        expDataFile: [],
        annoDataFile: [],
        sigsampletable: [],
        sigsampletableheader: [],
        siggrouptable: [],
        siggrouptableheader: [],
        showgroup: false,
        resultShow: true,
        loading: false,
        grouploading: false,
      };
    },
    created(){
      this.analysisData()
    },
  
    methods: {
      handleRemove(file, fileList) {
        console.log(file, fileList);
      },
      handlePreview(file) {
        console.log(file);
      },
      handleExceed(files, fileList) {
        this.$message.warning(`当前限制选择 3 个文件，本次选择了 ${files.length} 个文件，共选择了 ${files.length + fileList.length} 个文件`);
      },
      beforeRemove(file, fileList) {
        return this.$confi
        rm(`确定移除 ${ file.name }？`);
      },
      handleEdit(){
        window.open("/tiger/Download/" + "customSig_example.anno.tsv.zip");
      },
      getsampletableData(samplejsonUrl) {
        this.$http
          .get("/tiger/img/" + samplejsonUrl + ".json")
          .then((res) => {
            this.sigsampletable = res.data;
            this.sigsampletableheader = Object.keys(res.data[0]);
          })
          .catch((error) => {
            console.log(error);
          });
        this.loading = false;
      },
      getgrouptableData(groupjsonUrl){
        this.$http
          .get("/tiger/img/" + groupjsonUrl + ".json")
          .then(function(res2) {
            this.siggrouptable = res2.data;
            this.siggrouptableheader = Object.keys(res2.data[0]);
            console.log(siggrouptableheader);
          })
          .catch(function(error) {
            console.log(error);
          });
        this.grouploading = false;
      },
      analysisData(){
        var that = this;
        var expDataPath = "Download/customSig_example.exp.tsv";
        var annoDataPath = "Download/customSig_example.anno.tsv";
        that.loading = true;
        that.grouploading = true;
        this.$http
          .get("/tiger/2.4.1.sigscoreCustomTable.php", {
            params: {
                expfile: expDataPath,
                annofile: annoDataPath,
                keyid: "test",
            },
          })
          .then(function(res) {
            if (res.data.status == 0) {
              let imgpath = res.data.output[0].split(",");
              that.getsampletableData(imgpath[0]);
              if(imgpath[1] === "0"){
                that.grouploading = false;
              }else{
                that.getgrouptableData(imgpath[1])
              }
            }else{
              that.resultShow=false;
            }
          })
          .catch((error) => {
            console.log(error);
          });
      },
      // tableCellStyle({ row, column }) {
      //   if (row[column["label"]] === null) {
      //     return {
      //       background: "white",
      //     };
      //   }
      //   var mycolr = gStyle(
      //     parseFloat(
      //       row[column["label"]] === undefined
      //         ? ""
      //         : row[column["label"]]
      //     ),
      //     2.25
      //   );
      //   return {
      //     background: mycolr["background"],
      //     color: mycolr["color"],
      //   };
      // },
    }
  }
</script>

<style>
#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>