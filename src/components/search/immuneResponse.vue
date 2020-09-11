<template>
  <div>
    <v-resultcard
      :conditi="'Responder'"
      :seargene="seargene"
      :title="'Differential expression between responder and non-responder'"
      ref="immuResponseVueRefResponder"
    ></v-resultcard>
    <v-resultcard
      :conditi="'Therapy'"
      :seargene="seargene"
      :title="'Differential expression between pre-therapy and post-therapy'"
      ref="immuResponseVueRefTherapy"
    ></v-resultcard>
    <v-resultcard
      :conditi="'Survival'"
      :seargene="seargene"
      ref="immuResponseVueRefSurvival"
      :title="'Survival analysis'"
    ></v-resultcard>
  </div>
</template>

<script>
export default {
  props: {
    seargene: {type: String},
  },
  data() {
    return {
      oldseargene: "",
    };
  },

  mounted() {
    this.oldseargene = this.seargene;
  },

  methods: {
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.$refs.immuResponseVueRefResponder.getTableData(
          this.seargene,
          "Responder"
        );
        this.$refs.immuResponseVueRefTherapy.getTableData(
          this.seargene,
          "Therapy"
        );
        this.$refs.immuResponseVueRefSurvival.getTableData(
          this.seargene,
          "Survival"
        );
        
      }
    },
  },

  components: {
    "v-resultcard": () => import("./resultcard.vue"),
  },
};
</script>


<style>
.detailimg {
  text-align: center;
}
.scaterPlot {
  margin: 0 auto;
}
</style>
