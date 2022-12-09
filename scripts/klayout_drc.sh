echo "################   Running Klayout FEOL ########################"
klayout -b -r '$PDK_ROOT/$PDK/libs.tech/klayout/drc/sky130A_mr.drc' -rd input=gds/$1.gds -rd report=/project/signoff/$1/openlane-signoff/drc/klayout_feol_check.xml -rd feol=true

echo "################   Running Klayout BEOL ########################"
klayout -b  -r '$PDK_ROOT/$PDK/libs.tech/klayout/drc/sky130A_mr.drc' -rd input=gds/$1.gds -rd report=/project/signoff/$1/openlane-signoff/drc/klayout_beol_check.xml -rd beol=true

echo "################   Running Klayout Offgrid #####################"
	klayout -b -r '$PDK_ROOT/$PDK/libs.tech/klayout/drc/sky130A_mr.drc' -rd input=gds/$1.gds -rd report=/project/signoff/$1/openlane-signoff/drc/klayout_offgrid_check.xml -rd offgrid=true

echo "################   Klayout Metal Minimum Clear Area Density #####################"
klayout -b -r '$PDK_ROOT/$PDK/libs.tech/klayout/drc/met_min_ca_density.lydrc' -rd input=gds/$1.gds -rd report=/project/signoff/$1/openlane-signoff/drc/klayout_met_min_ca_density_check.xml

echo "### Klayout Zero Area check command ####"
klayout -b -r '$PDK_ROOT/$PDK/libs.tech/klayout/drc/zeroarea.rb.drc' -rd input=gds/$1.gds -rd report=/project/signoff/$1/openlane-signoff/drc/klayout_zeroarea_check.xml -rd cleaned_output=outputs/dac_top_no_zero_areas.gds

echo "## klayout_pin_label_purposes_overlapping_drawing_check"
klayout -b -r '$PDK_ROOT/$PDK/libs.tech/klayout/drc/pin_label_purposes_overlapping_drawing.rb.drc' -rd input=gds/$1.gds -rd report=/project/signoff/$1/openlane-signoff/drc/klayout_pin_label_purposes_overlapping_drawing_check.xml -rd top_cell_name=$1
echo "You can find results for all corners in ./signoff/$1/openlane-signoff/drc/"

