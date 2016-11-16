require 'spec_helper'
require 'cfn_nag'


describe CfnNag do
  before(:all) do
    CfnNag::configure_logging({debug: false})
    @cfn_nag = CfnNag.new
  end

  def test_template(template_name)
    File.new(File.join(__dir__, 'test_templates', template_name))
  end

  context 'igw exists' do

    it 'flags a violation' do
      template_name = 'with_igw.json'

      expected_aggregate_results = [
        {
          filename: File.join(__dir__, 'test_templates/with_igw.json'),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(type: Violation::FAILING_VIOLATION,
                            message: 'Internet Gateways are not allowed',
                            logical_resource_ids: %w(myInternetGateway),
                            violating_code: nil)
            ]
          }
        }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
