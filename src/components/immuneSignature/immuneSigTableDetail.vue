<template>
    <div>
        <p class="card-title">{{sigID}}</p>
        <el-row class="detailimg">
            <el-col push="1" span="22">
                <p class="card-title">Signature Informations</p>
                <el-table :data="articleData" style="width: 100%" v-loading="artloading">
                    <el-table-column prop="title" label width="180"></el-table-column>
                    <el-table-column prop="value" label></el-table-column>
                </el-table>
                <p class="card-title">Signature Component</p>
                <p class="card-title">AUC Table</p>
                <p class="card-title">Signature Score in Different Cancer Type (Response vs Non-Response)</p>
                <p class="card-title">Signature Score in Different Cancer Type (Tumor vs Normal)</p>
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
        }
    },
    created(){
        this.articleDetail(this.sigID)
    },
    mounted(){
        this.articleDetail(this.sigID)
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
                console.log( res.data.list)
            that.articleData = res.data.list;
            that.artloading = false;
            })
            .catch(function (res) {
            console.log(res);
            });
            console.log(this.articleData)
        },
    }
}
</script>

<style>

</style>