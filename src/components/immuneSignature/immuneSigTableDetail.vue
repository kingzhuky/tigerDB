<template>
    <div>
        <p class="card-title">{{sigID}}</p>
        <el-row class="detailimg">
            <el-col push="1" span="22">
                <p class="card-title">Signature Informations</p>
                <el-table :data="articleData" style="width: 100%" v-loading="artloading">
                    <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
                    <el-table-column prop="title" label width="250">
                        <template slot-scope="{row: {title}}">
                        <span v-if="title === 'SignatureID'">Signature ID</span>
                        <span v-else-if="title === 'SignatureName'">Signature Name</span>
                        <span v-else-if="title === 'SignatureCite'">Signature Cite</span>
                        <span v-else>{{title}}</span>
                        </template>
                    </el-table-column>
                    <el-table-column label>
                        <template slot-scope="scope">
                        <span v-if="scope.row.title === 'PMID'">
                            <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.value"
                            target="_blank"
                            class="buttonText">{{scope.row.value}}</a>
                            </span>
                        <span v-else><a v-html="scope.row.value"></a></span>
                        </template>
                    </el-table-column>
                </el-table>
                <!-- <p class="card-title">Signature Component</p> -->
                <p class="card-title">AUC Table</p>
                    <el-row v-loading="aucTableloading">
                    <el-table
                        :data="aucTableData"
                        max-height="520"
                        style="width: 100%"
                        :row-key="getRowKeys"
                        :expand-row-keys="expands"
                        @expand-change="diffExpRespontableExpand"
                    >
                        <!-- <el-table-column type="expand">
                        <template slot-scope="props">
                            <div class="detailimg" v-loading="picScatterloading">
                            <img width="450px" :src="picScatter" v-show="detailimgShow" />
                            <div v-show="!detailimgShow">no result</div>
                            </div>
                        </template>
                        </el-table-column> -->
                        <el-table-column prop="dataset_id" label="Dataset ID"></el-table-column> 
                        <el-table-column prop="Dataset" label="Dataset" sortable></el-table-column>
                        <el-table-column property="PMID" label="PMID" align="center">
                            <template slot-scope="scope">
                            <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                                target="_blank"
                                class="buttonText">{{scope.row.PMID}}</a>
                            </template>
                        </el-table-column>
                        <el-table-column prop="SampleSize" label="Sample Size" sortable></el-table-column>
                        <el-table-column prop="Therapy" label="Therapy"></el-table-column>
                        <el-table-column 
                            :prop="sigID" 
                            label="AUC"
                            sortable
                        ></el-table-column>
                        <!-- <el-table-column prop="COEAID" label="COEAID"></el-table-column> -->
                        <!-- <el-table-column prop="SCID" label="SCID"></el-table-column> -->
                    </el-table>
                    </el-row>
                <p class="card-title">Signature Score in Different Cancer Type (Response vs Non-Response)</p>
                    <img height="400px" :src="imgUrlRNRBox" />
                <p class="card-title">Signature Score in Different Cancer Type (Tumor vs Normal)</p>
                    <img height="400px" :src="imgUrlTNBox" />
            </el-col>
        </el-row>
    </div>
</template>

<script>

export default {
    props:{
        sigID: String,
    },
    data(){
        return{
            articleData: [],
            artloading: true,
            imgpathRNRBox: "",
            imgpathTNBox: "",
            aucTableloading: false,
            aucTableData: [],
        }
    },
    created(){
        this.renewDetail(this.sigID)
    },
    mounted(){
        this.renewDetail(this.sigID)
    },
    computed: {
        imgUrlRNRBox: function() {
        return "tiger/img/" + this.imgpathRNRBox + ".png";
        },
        imgUrlTNBox: function() {
        return "tiger/img/" + this.imgpathTNBox + ".png";
        },
    },
    methods:{
        renewDetail(sigID){
            this.articleDetail(sigID)
            this.getDiagramData(sigID)
        },
        articleDetail(sigID) {
            console.log(sigID)
            var that = this;
            that.artloading = true;
            this.$http
            .get("/tiger/immunescreendetail2.php", {
                params: {
                    tabl: "siginfo",
                    colu: "SignatureID",
                    coluvalue: sigID,
                },
            })
            .then(function (res) {
                // console.log(res.data.list)
                that.articleData = res.data.list;
                that.imgpathRNRBox = "ImmuneSig-Detial-RNR-boxplot-" + sigID
                that.imgpathTNBox = "ImmuneSig-Detial-pancancer-boxplot-" + sigID
                console.log(that.imgpathTNBox)
                that.artloading = false;
            })
            .catch(function (error) {
                console.log(error);  
            });
            // console.log(this.articleData)
        },
        getDiagramData(sigID) {
            this.aucTableData = [];
            this.aucTableloading = true;
            this.$http
            .get("/tiger/searchAucTable.php", {
                params: {
                    sigid: sigID,
                },
            })
            .then((res) => {
                if (res.data.status === 200) {
                    this.aucTableData = res.data.list;
                    this.total = res.data.total[0];
                    this.aucTableloading = false;
                    console.log(aucTableData)
                }
            })
            .catch((error) => {
                console.log(error);
            });
        },
        getRowKeys: function (row) {
            return row.geneb;
        },
        diffExpRespontableExpand: function (row, expandedRows) {
            var that = this;
            if (expandedRows.length) {
                that.expands = [];
                if (row) {
                that.expands.push(row.geneb);
                }
            } else {
                that.expands = [];
            }

            this.picScatterPlot(
                row.datasetid,
                row.GlobalCluster,
                row.genea,
                row.geneb,
                row.CellType
            );
        },
    }
}
</script>

<style>

</style>