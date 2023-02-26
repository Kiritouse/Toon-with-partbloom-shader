Shader "Hidden/Bloom Replace" 
{
	//替换标签是Bloom的shader
    SubShader
	{
	   Tags { "RenderType" = "Bloom" }
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;

			half4 frag(v2f_img i) : COLOR
			{
				return tex2D(_MainTex,i.uv);
			}
			ENDCG
		}
    }

	//替换标签是BloomTransparent的shader
	SubShader
	{
		Tags{ "RenderType" = "BloomTransparent" }//透明渲染，其实可以不用管，但为了后续开发还是写上
		Blend SrcAlpha One
		Cull Off Lighting Off ZWrite Off Fog{ Mode Off }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			half4 frag(v2f_img i) : COLOR
			{
				return tex2D(_MainTex,i.uv);
			}
			ENDCG
		}
	}
    
	//替换标签是Opaque的shader，这里直接渲染为黑色
    SubShader 
	{
        Tags { "RenderType" = "Opaque" }//对于这个标签为Opaque的shader，我们渲染成为黑色
        Pass 
		{    
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"
            half4 frag(v2f_img i) : COLOR
            {
                return half4(0,0,0,0);
            }
            ENDCG
        }
    }   
	Fallback Off
}
