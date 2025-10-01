({
    unrender: function (component) {
    	this.superUnrender();
        window.clearInterval(component.get("v.popssition"));
	}
})