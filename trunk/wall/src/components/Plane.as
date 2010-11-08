package components
{

import components.capabilities.Movability;
import components.capabilities.Pannability;

import flash.geom.Rectangle;

import spark.components.BorderContainer;
import spark.primitives.Rect;

public class Plane extends SpatialObject
{
	
	private var movability:Movability;
	private var resizability:Object;
	private var pannability:Pannability;
	private var rotatability:Object;
	private var scalability:Object;
	
	public function Plane()
	{
		super();
		movability = new Movability(this);
//		resizability = new Resizability(this);
		pannability = new Pannability(this, childrenHolder);
//		scalability = new Scalability(this);
		
	}

}
}