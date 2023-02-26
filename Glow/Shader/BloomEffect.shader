Shader "BloomEffect" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BlurTex("Blur", 2D) = "white"{}
		__bloomFactor("bloomFactor",Range(0,10)) = 1
	}

		CGINCLUDE
#include "UnityCG.cginc"

	//用于阈值提取高亮部分
	struct v2f_threshold
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	//用于blur
	struct v2f_blur
	{
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
		float4 uv01 : TEXCOORD1;
		float4 uv23 : TEXCOORD2;
		float4 uv45 : TEXCOORD3;
	};

	//用于bloom
	struct v2f_bloom
	{
		float4 pos : SV_POSITION;
		float2 uv  : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	// XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1 / width, y = 1 / height, z = width, w = height
	sampler2D _BlurTex;
	float4 _BlurTex_TexelSize;
	float4 _offsets;
	float4 _colorThreshold;
	float4 _bloomColor;
	float _bloomFactor;

	//高亮部分提取shader
	v2f_threshold vert_threshold(appdata_img v)
	{
		v2f_threshold o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;//获取纹理坐标
		
#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1 - o.uv.y;
#endif
		return o;
	}

	fixed4 frag_threshold(v2f_threshold i) : SV_Target
	{
		fixed4 color = tex2D(_MainTex, i.uv);
		//仅当color大于设置的阈值的时候才输出
		return saturate(color - _colorThreshold);
	}

		//高斯模糊 vert shader
	v2f_blur vert_blur(appdata_img v)
	{
		v2f_blur o;
		_offsets *= _MainTex_TexelSize.xyxy;//防止偏移值超过屏幕坐标，所以超过的部分就除以屏幕的尺寸
		//在c#脚本中传入如果是（0，1，0，0）代表是横向模糊
		//如果是（1，0，0，0）代表是纵向模糊
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;//获取纹理坐标
		//UV偏移启动！
		//这里的运算符重载了的	（0，1，0，1）*（1，1，-1，-1） = （0,1,0-1）对应分量相乘
		//也就是哈达玛积
		o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);
		o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;
		o.uv45 = v.texcoord.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 3.0;

		return o;
	}

	//高斯模糊 pixel shader
	fixed4 frag_blur(v2f_blur i) : SV_Target
	{
		fixed4 color = fixed4(0,0,0,0);
		color += 0.40 * tex2D(_MainTex, i.uv);
		color += 0.15 * tex2D(_MainTex, i.uv01.xy);
		color += 0.15 * tex2D(_MainTex, i.uv01.zw);
		color += 0.10 * tex2D(_MainTex, i.uv23.xy);
		color += 0.10 * tex2D(_MainTex, i.uv23.zw);
		color += 0.05 * tex2D(_MainTex, i.uv45.xy);
		color += 0.05 * tex2D(_MainTex, i.uv45.zw);
		//用7x1的高斯核进行卷积运算
         //前面这几个值是提前运算好的，一来保证权重和为一，而来又符合高斯分布
		return color;
	}

	//Bloom效果 vertex shader
	v2f_bloom vert_bloom(appdata_img v)
	{
		v2f_bloom o;
		//mvp矩阵变换
		o.pos = UnityObjectToClipPos(v.vertex);
		//uv坐标传递
		o.uv.xy = v.texcoord.xy;
		o.uv1.xy = o.uv.xy;
		
#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1 - o.uv.y;
#endif	
		return o;
	}

	fixed4 frag_bloom(v2f_bloom i) : SV_Target
	{
		//取原始清晰图片进行uv采样
		fixed4 ori = tex2D(_MainTex, i.uv1);
		//取高斯模糊进行uv采样
		fixed4 blur = tex2D(_BlurTex, i.uv);
		//输出= 原始图像，叠加bloom权值*bloom颜色*泛光颜色
		fixed4 final = ori + _bloomFactor * blur * _bloomColor;
		return final;
	}

	ENDCG

	SubShader
	{
		//pass 0: 提取高亮部分
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }

			CGPROGRAM
            #pragma vertex vert_threshold
            #pragma fragment frag_threshold
			ENDCG
		}

		//pass 1: 高斯模糊
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }

			CGPROGRAM
#pragma vertex vert_blur
#pragma fragment frag_blur
			ENDCG
		}

		//pass 2: Bloom效果
		Pass
		{

			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }

			CGPROGRAM
#pragma vertex vert_bloom
#pragma fragment frag_bloom
			ENDCG
		}

	}
}
