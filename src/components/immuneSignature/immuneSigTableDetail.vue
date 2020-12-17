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
                <p class="card-title">Signature Component</p>
                <p class="card-title">AUC Table</p>

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
        }
    },
    created(){
        this.articleDetail(this.sigID)
    },
    mounted(){
        this.articleDetail(this.sigID)
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
            .catch(function (res) {
                console.log(res);  
            });
            // console.log(this.articleData)
        },
    }
}
</script>

<style>

</style>