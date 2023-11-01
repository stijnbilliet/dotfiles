import os
import io
import sys
import argparse
import inspect
import re
import yaml

def type_dir_path(argstring):
    if os.path.isdir(argstring):
        return argstring
    else:
        raise argparse.ArgumentTypeError(f"Directory {argstring} is not a valid path")

def type_dir_path_new(argstring):
    if os.path.exists(os.path.dirname(argstring)):
        if os.path.isdir(argstring):
            return argstring
        else:
            os.makedirs(os.path.normpath(argstring));
    else:
        raise argparse.ArgumentTypeError(f"Path specified seems malformed {argstring}");

def type_file_path(argstring):
    if os.path.isfile(argstring):
        return argstring
    else:
        raise argparse.ArgumentTypeError(f"{argstring} is not a file or doesn't exist")

def col(key: str, is_light_theme: bool) -> str:
    if key:
        return key;
    else:
        if is_light_theme:
            return "0x000000";
    return "0xffffff";
    

def yaml_to_colors(in_yaml: dict, is_light_theme: bool) -> dict:
    # Base-16 encoding, alacritty flavour if you will
    out_col_dict = {};

    # Parent node
    in_col_dict = in_yaml['colors'];

    # Dict parent groups
    primary_colors = in_col_dict['primary'];
    normal_colors = in_col_dict['normal'];
    accent_colors = in_col_dict['bright'];

    # Primaries
    out_col_dict['background'] = primary_colors['background'];
    out_col_dict['foreground'] = primary_colors['foreground'];
    out_col_dict['cursor'] = col(primary_colors.get('cursor'), is_light_theme);

    # Normal
    color_id = 0;
    for in_key in normal_colors: # First eight colors
        out_key = "color" + str(color_id);
        out_col_dict[out_key] = normal_colors[in_key];
        color_id += 1;

    # Accents
    for in_key in accent_colors: # Next eight
        out_key = "color" + str(color_id);
        out_col_dict[out_key] = accent_colors[in_key];
        color_id += 1;
    
    return out_col_dict;

def template_line_replace_token(line: str, in_colors: dict):
    # Assume they are defined in order, but don't assert it
    for n, t in in_colors.items():
        needle = "{" + n + "}";
        sub_result = re.subn(needle, t, line, 1);
        if sub_result[1] != 0: # A replacement was made
            in_colors.pop(n);
            # TODO(stijn): in case I want to write out replacements found, print sub_results to the correct bus;
            return sub_result[0];
    return line;

def template_file_export(in_colors: dict, in_template_file, output_directory):
    output_stream = io.StringIO();
    with open(in_template_file, 'r') as file:
        # Split to list based on line-ending
        lines = file.read().splitlines(True);
        colors_sewing_kit = in_colors.copy();
        for line in lines:
            output_stream.write(template_line_replace_token(line, colors_sewing_kit));

    # Export to output directory
    in_template_file_name = os.path.basename(in_template_file).split('/')[-1];
    output_file_path = os.path.join(output_directory, in_template_file_name);

    print(output_stream.getvalue(), file=open(output_file_path, "w"));



def color_format_exchanger(theme_path: os.PathLike, template_dir: os.PathLike, output_dir: os.PathLike, is_light_theme : bool = False):
    # Get yaml dictionary from theme file
    with open(theme_path, 'r') as file:
        theme_yaml = yaml.safe_load(file);
    
    # Get theme colors from yaml dictionary
    theme_colors = yaml_to_colors(theme_yaml, is_light_theme);

    for template in os.scandir(template_dir):
        if template.is_file():
            template_file_export(theme_colors, template, output_dir);


def main():
    mainparser = argparse.ArgumentParser(description="Just a chirpy script");
    mainparser.add_argument("-t", "--theme", type=type_file_path, required=True, help="Theme specification file, see ./themes for predefined definitions.");
    mainparser.add_argument("-l", "--light", type=type_file_path, help="Theme specification file, see ./themes for predefined definitions. Can be specified together with the '--theme', which will act as the dark theme.");
    mainparser.add_argument("-o", "--outdir", required=False, type=type_dir_path_new, help="Enable with alternate output directory if specified, if not defined the cross platform equivalents of home/user/.config/cfx will be used.");
    args = vars(mainparser.parse_args());

    output_directory_default = os.path.join(os.path.expanduser("~"), ".config/cfx/");
    dark_theme_def = args['theme'];
    light_theme_def = args['light'];
    output_directory = args['outdir'] if args['outdir'] else output_directory_default;

    if not os.path.exists(output_directory):
        os.makedirs(output_directory);
    
    script_path = os.path.dirname(os.path.abspath(__file__));
    templates_def_dir = os.path.join(script_path, "templates");
    if not os.path.isdir(templates_def_dir):
        raise NotADirectoryError("Template directory could not be found, should be next to cfx.py file.")

    # Read dark theme
    color_format_exchanger(dark_theme_def, templates_def_dir, output_directory);

    # Read light theme (if specified)
    if light_theme_def:
        color_format_exchanger(light_theme_def, templates_def_dir, output_directory, True);

if __name__ == "__main__":
    main()