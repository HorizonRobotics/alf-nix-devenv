# The sha256 in this file can be fetched by calling
#
# nix-prefetch-url <URL>

{ version, pyVerNoDot }:

let urls = {
      "2.0.1" = {
        "37" = {
          url = https://files.pythonhosted.org/packages/62/24/9ddaf1d3e0e88d9866a0d67ad5d3c9d3f82ea5f819435d76f6654e1fddf2/rectangle_packer-2.0.1-cp37-cp37m-manylinux2010_x86_64.whl;
          sha256 = "0gfcmwr7k1ifrmk7mwzfzyp8hh163mrjik572xn1d4j53l78qq5h";
        };

        "38" = {
          url = https://files.pythonhosted.org/packages/a5/83/13f95641e7920c471aff5db609e8ccff1f4204783aff63ff4fd51229389e/rectangle_packer-2.0.1-cp38-cp38-manylinux2010_x86_64.whl;
          sha256 = "00z2dnjv5pl44szv8plwlrillc3l7xajv6ncdf5sqxkb0g0r3kc6";
        };

        "39" = {
          url = https://files.pythonhosted.org/packages/c6/f3/2ca57636419c42b9a698a6378ed99a61bcff863db53a1ec40f0edd996099/rectangle_packer-2.0.1-cp39-cp39-manylinux2010_x86_64.whl;
          sha256 = "1kxy7kqs6j9p19aklx57zjsbmnrvqngs6zdi2s8c4qvshm3zzayk";
        };

        "310" = {
          url = https://files.pythonhosted.org/packages/64/e1/8813040585c125fb42671357a3f1d22d95951733e9fc1ec9f787dcded196/rectangle_packer-2.0.1-cp310-cp310-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl;
          sha256 = "0qjbgwcqjkaf12rq8dgzrjb443j34dpdh9cicl8qxhqjbzaz3ih6";
        };
      };
    };
in urls."${version}"."${pyVerNoDot}"
