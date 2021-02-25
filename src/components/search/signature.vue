<template>
  <div>
    <wersignature ref="immuneSignatureTableRef" :gene="gene"></wersignature>
  </div>
</template>

<script>
import wersignature from "../immuneSignature/immuneSigCorTable";

export default {
  props: {
    gene: String,
  },
  data() {
    return {
      oldgene:""
    };
  },

  methods: {
    plot() {
      if ((this.oldgene !== this.gene) | (this.oldgene === "")) {
        this.oldgene = this.gene;
        this.$refs.immuneSignatureTableRef.getTableData("expresponse", 1);
      }
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.plot();
    });
  },
  components: {
    wersignature: wersignature,
  },
};
</script>


<style>
</style>
