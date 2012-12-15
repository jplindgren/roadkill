﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Mvc;
using Recaptcha;
using Roadkill.Core.Configuration;

namespace Roadkill.Core
{
	/// <summary>
	/// Represents an attribute that is added to indicate that the action requires a
	/// Recaptcha response. Use this in conjunection with [HttpPost] and @Html.GenerateCaptcha()
	/// </summary>
	public class RecaptchaRequiredAttribute : ActionFilterAttribute
	{
		private static readonly string CHALLENGE_KEY = "recaptcha_challenge_field";
		private static readonly string RESPONSE_KEY = "recaptcha_response_field";

		public override void OnActionExecuting(ActionExecutingContext filterContext)
		{
			Roadkill.Core.Controllers.ControllerBase controller = filterContext.Controller as Roadkill.Core.Controllers.ControllerBase;
			if (controller != null)
			{
				if (controller.Configuration.SitePreferences.IsRecaptchaEnabled)
				{
					string challengeValue = filterContext.HttpContext.Request.Form[CHALLENGE_KEY];
					string responseValue = filterContext.HttpContext.Request.Form[RESPONSE_KEY];

					RecaptchaValidator validator = new RecaptchaValidator();
					validator.PrivateKey = controller.Configuration.SitePreferences.RecaptchaPrivateKey;
					validator.RemoteIP = filterContext.HttpContext.Request.UserHostAddress;
					validator.Challenge = challengeValue;
					validator.Response = responseValue;

					RecaptchaResponse validationResponse = validator.Validate();
					filterContext.ActionParameters["isCaptchaValid"] = validationResponse.IsValid;
				}
			}

			base.OnActionExecuting(filterContext);
		}
	}
}