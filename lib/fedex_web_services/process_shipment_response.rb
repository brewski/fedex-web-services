require 'base64'

module FedexWebServices
  class ProcessShipmentResponse < Response
    def label_images
      contents.completedShipmentDetail.completedPackageDetails.map do |details|
        Base64.decode64(details.label.parts.map { |p| Base64.decode64(p.image) } * "")
      end
    end

    def tracking_ids
      contents.completedShipmentDetail.completedPackageDetails.map do |details|
        details.trackingIds
      end
    rescue
      raise Api::ServiceException, "Unable to extract tracking number from response"
    end

    def package_rates
      contents.completedShipmentDetail.completedPackageDetails.map do |details|
        details.packageRating.packageRateDetails.inject(0) do |acc, rate|
          rate.rateType == FedexWebServices::Soap::Ship::ReturnedRateType::PAYOR_ACCOUNT_PACKAGE ?
              acc + BigDecimal(rate.netCharge.amount) :
              acc
        end
      end
    rescue
      raise Api::ServiceException, "Unable to extract rate information from response"
    end
  end
end
