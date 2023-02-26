Shader "Hidden/Bloom Replace" 
{
	//�滻��ǩ��Bloom��shader
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

	//�滻��ǩ��BloomTransparent��shader
	SubShader
	{
		Tags{ "RenderType" = "BloomTransparent" }//͸����Ⱦ����ʵ���Բ��ùܣ���Ϊ�˺�����������д��
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
    
	//�滻��ǩ��Opaque��shader������ֱ����ȾΪ��ɫ
    SubShader 
	{
        Tags { "RenderType" = "Opaque" }//���������ǩΪOpaque��shader��������Ⱦ��Ϊ��ɫ
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
