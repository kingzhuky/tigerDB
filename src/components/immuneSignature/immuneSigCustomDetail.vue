<template>
    <div v-loading="loading">
        <el-row>
            <p class="card-title">Signature Score Table</p>
            <div class="detailimg">
            <el-table
                id="immuneSigTable"
                class="tigtablele"
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
        </el-row>
        <el-row v-show="isgroupshow">
            <p class="card-title">Signature Score Table</p>
            <div class="detailimg">
            <el-table
                id="immuneSigTable"
                class="tigtablele"
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
        <el-row>
            <!-- <p class="card-title">Signature Score Table</p> -->
            <v-sigdetail
                ref="immuneSigDetail"
                v-show="isShow"
                :sigID="sigID"
            ></v-sigdetail>
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
        props:{
            expDataPath: String,
            annoDataPath: String,
            taskuid: String,
        },
        data() {
            return {
                fileList: [],
                sigsampletable: [],
                sigsampletableheader: [],
                siggrouptable: [],
                siggrouptableheader: [],
                showgroup: false,
                resultShow: true,
                loading: false,
                grouploading: false,
                isgroupshow: false,
                sigID: "",
                isShow: false,
            };
        },
        created(){
            // this.analysisData(this.expDataPath,this.annoDataPath,this.taskuid)
        },
    
        methods: {
            getsampletableData(samplejsonUrl) {
                this.$http
                    .get("/tiger/img/" + samplejsonUrl + ".json")
                    .then((res) => {
                        this.sigsampletable = res.data;
                        this.sigsampletableheader = Object.keys(res.data[0]);
                        console.log( res.data);
                    })
                    .catch((error) => {
                        console.log(error);
                    });
                this.loading = false;
            },
            getgrouptableData(groupjsonUrl){
                this.$http
                    .get("/tiger/img/" + groupjsonUrl + ".json")
                    .then((res2) => {
                        this.siggrouptable = res2.data;
                        this.siggrouptableheader = Object.keys(res2.data[0]);
                        console.log(siggrouptableheader);
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                this.grouploading = false;
            },
            analysisData(expDataPath, annoDataPath, taskuid){
                var that = this;
                that.loading = true;
                that.grouploading = true;
                this.$http
                .get("/tiger/2.4.1.sigscoreCustomTable.php", {
                    params: {
                        expfile: expDataPath,
                        annofile: annoDataPath,
                        keyid: taskuid,
                    },
                })
                .then(function(res) {
                    if (res.data.status == 0) {
                        let imgpath = res.data.output[0].split(",");
                        that.getsampletableData(imgpath[0]);
                        if(imgpath[1] === "0"){
                            that.grouploading = false;
                            that.isgroupshow = false;
                        }else{
                            that.getgrouptableData(imgpath[1])
                            that.isgroupshow = true;
                            that.grouploading = false;
                        }
                    }else{
                        that.resultShow=false;
                    }
                })
                .catch((error) => {
                    console.log(error);
                });
            },
            //点击单个格子
            heandleclick(row, column) {
                this.datatype = "immunescreening";
                if (column["label"] !== "sample_id" && column["label"] !== "group") {
                    this.isShow = true;
                    this.sigID = column["label"]
                    this.$refs.immuneSigDetail.renewDetail(this.sigID)
                    // this.m6aMsg = row["gene"];
                    // this.cancerMsg = column["label"];
                    // setTimeout(() => { toTarget(820) }, 200); 
                    // this.$refs.detailPlot.tableDetail(row["gene"]);
                    // this.$refs.detailPlot.artivcleDetail(column["label"]);
                }else{
                    this.isShow = false;
                }

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
        },
        components: {
            "v-sigdetail": () => import("./immuneSigTableDetail.vue"),
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
</style>