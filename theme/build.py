"""Build dotfiles from Jinja2 templates and color definitions."""

from pathlib import Path

from jinja2 import Environment, FileSystemLoader, StrictUndefined
import yaml


ROOT = Path(__file__).resolve().parent
DOTFILES = ROOT.parent
TEMPLATES = ROOT / "templates"
COLORS_PATH = ROOT / "colors.yaml"


def load_colors():
    """Load color definitions from the YAML file.

    Returns:
        dict: A dictionary containing color definitions.
    """
    colors_path = ROOT / "colors.yaml"
    return yaml.safe_load(colors_path.read_text(encoding="utf-8"))


def main():
    """Render all Jinja2 templates in the templates directory.

    Returns:
        None
    """
    colors = load_colors()

    env = Environment(
        autoescape=True,
        loader=FileSystemLoader(str(TEMPLATES)),
        undefined=StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
    )

    for tpl_path in TEMPLATES.rglob("*.j2"):
        rel = tpl_path.relative_to(TEMPLATES)
        out_rel = rel.with_suffix("")  # Remove .j2 suffix
        out_path = DOTFILES / out_rel

        template = env.get_template(str(rel))
        rendered = template.render(**colors)

        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(rendered, encoding="utf-8")
        print(f"Rendered: {out_path}")


if __name__ == "__main__":
    main()
