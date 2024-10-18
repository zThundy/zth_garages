
export function loadStaticSvg(name) {
    console.log("called loadStaticSvg", name);
    if (process.env.NODE_ENV === "development") {
        return "/svg/" + name + ".svg";
    } else {
        return "/html/svg/" + name + ".svg";
    }
}