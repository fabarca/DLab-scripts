#
# Yerko Escalona, December 2012
#
# script to show residues around of a ligand like CHIMERA
#
# before you run this script, is useful get the protein with the cartoon
# respresentation
#

from pymol import cmd

def residues_around_ligand (selection="het"):
    #
    # Usage:
    #       run /path/to/residues_around_ligand.py
    #       sele ATP, resname ATP
    #       residues_around_ligand ATP
    #

    cmd.select("near", "%s around 5" % selection)
    cmd.select("nearres", "br. near")
    cmd.select("sidechain", "not (name c+n+o) in nearres")
    cmd.show("sticks", "nearres")
    cmd.label("n. CA and nearres", '"%s, %s" % (resn, resi)')
    cmd.set("label_color", "white", "sidechain")
    cmd.set("label_size", "-0.6")
    cmd.color("blue", "name n*")
    cmd.color("red", "name o*")
    cmd.deselect()

cmd.extend("residues_around_ligand",residues_around_ligand)
